import asyncio
import base64
import copy
import hashlib
import json
import os
import secrets
import sys

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.x25519 import X25519PrivateKey
from remnawave import RemnawaveSDK
from remnawave.models import (
    CreateConfigProfileRequestDto,
    CreateHostInboundData,
    CreateHostRequestDto,
    CreateInternalSquadRequestDto,
    CreateUserBodyDto,
    UpdateConfigProfileRequestDto,
    UpdateHostRequestDto,
    UpdateInternalSquadRequestDto,
)


API_PORT = int(os.environ["API_PORT"])
API_BASE_URL = f"http://127.0.0.1:{API_PORT}"
API_TOKEN = os.environ["API_TOKEN"]
NODES_FILE = os.environ["NODES_FILE"]
MASK_PORT = int(os.environ["MASK_PORT"])
ADGUARD_DOMAIN = os.environ.get("ADGUARD_DOMAIN", "")

DEFAULT_SQUAD_NAME = "Default-Squad"


class ApiError(RuntimeError):
    pass


def warn(message):
    print(f"Remnawave bootstrap warning: {message}", file=sys.stderr)


# --- crypto helpers ---------------------------------------------------------


def encode_x25519_key(value):
    return base64.urlsafe_b64encode(value).decode().rstrip("=")


def decode_x25519_key(value):
    return base64.urlsafe_b64decode(value + "=" * (-len(value) % 4))


def public_key_from_private(private_key):
    key = X25519PrivateKey.from_private_bytes(decode_x25519_key(private_key))
    value = key.public_key().public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw,
    )
    return encode_x25519_key(value)


def keypair():
    private = X25519PrivateKey.generate()
    private_value = private.private_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PrivateFormat.Raw,
        encryption_algorithm=serialization.NoEncryption(),
    )
    public_value = private.public_key().public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw,
    )
    return {
        "privateKey": encode_x25519_key(private_value),
        "publicKey": encode_x25519_key(public_value),
    }


def short_ids():
    return [secrets.token_hex(8) for _ in range(8)]


def random_path():
    return f"/{secrets.token_hex(12)}"


def find_by_name(items, name):
    return next((item for item in items if item.name == name), None)


def replace_by_uuid(items, replacement):
    """Replace an API object in a local collection."""
    for index, item in enumerate(items):
        if item.uuid == replacement.uuid:
            items[index] = replacement
            return
    raise ApiError(f"API object {replacement.uuid!r} is not cached")


def inbound_uuid(profile, tag):
    inbound = next((item for item in profile.inbounds if item.tag == tag), None)
    if inbound is None:
        raise ApiError(f"{profile.name}: inbound {tag!r} has no UUID")
    return inbound.uuid


def inbound_uuids(profile):
    return [item.uuid for item in profile.inbounds]


# --- xray building blocks ---------------------------------------------------


def reality_inbound(tag, port, domain, pair, ids, path):
    return {
        "tag": tag,
        "port": port,
        "protocol": "vless",
        "settings": {"users": [], "decryption": "none"},
        "sniffing": {
            "enabled": True,
            "destOverride": ["http", "tls", "quic"],
            "routeOnly": True,
        },
        "streamSettings": {
            "network": "xhttp",
            "security": "reality",
            "xhttpSettings": {"path": path, "mode": "auto"},
            "realitySettings": {
                "show": False,
                "xver": 1,
                "target": f"127.0.0.1:{MASK_PORT}",
                "shortIds": ids,
                "privateKey": pair["privateKey"],
                "password": pair["publicKey"],
                "serverNames": [domain],
            },
        },
    }


def gate_outbound(tag, connection, vless_uuid):
    return {
        "tag": tag,
        "protocol": "vless",
        "settings": {
            "address": connection["domain"],
            "port": 443,
            "id": vless_uuid,
            "encryption": "none",
            "flow": "",
            "level": 0,
        },
        "streamSettings": {
            "network": "xhttp",
            "security": "reality",
            "xhttpSettings": {"path": connection["path"], "mode": "auto"},
            "realitySettings": {
                "serverName": connection["domain"],
                "fingerprint": "firefox",
                "password": connection["publicKey"],
                "shortId": connection["shortId"],
            },
        },
    }


def base_outbounds():
    return [
        {"tag": "DIRECT", "protocol": "freedom"},
        {"tag": "BLOCK", "protocol": "blackhole"},
    ]


def block_rules():
    return [
        {"ip": ["geoip:private"], "outboundTag": "BLOCK"},
        {"domain": ["geosite:private"], "outboundTag": "BLOCK"},
        {"protocol": ["bittorrent"], "outboundTag": "BLOCK"},
    ]


def ru_direct_rules():
    return [
        {"domain": ["geosite:category-ru"], "outboundTag": "DIRECT"},
        {"ip": ["geoip:ru"], "outboundTag": "DIRECT"},
    ]


def profile_config(inbounds, outbounds, rules):
    config = {
        "log": {"loglevel": "warning"},
        "inbounds": inbounds,
        "outbounds": outbounds,
        "routing": {"domainStrategy": "IPIfNonMatch", "rules": rules},
    }
    if ADGUARD_DOMAIN:
        config["dns"] = {
            "servers": [
                {
                    "address": f"https://{ADGUARD_DOMAIN}/dns-query",
                    "skipFallback": False,
                }
            ],
            "queryStrategy": "UseIPv4",
        }
    return config


def inbound_public_key(inbound):
    reality = inbound.get("streamSettings", {}).get("realitySettings", {})
    key = reality.get("password") or reality.get("publicKey")
    if key:
        return key
    private_key = reality.get("privateKey")
    if not private_key:
        raise ApiError(f"inbound {inbound.get('tag')!r}: no Reality key")
    return public_key_from_private(private_key)


def ensure_inbound_public_key(inbound):
    """Backfill the panel-facing public key; returns True when mutated."""
    reality = inbound.get("streamSettings", {}).get("realitySettings")
    if not isinstance(reality, dict):
        return False
    if reality.get("password") or reality.get("publicKey") or not reality.get(
        "privateKey"
    ):
        return False
    reality["password"] = public_key_from_private(reality["privateKey"])
    return True


# --- panel client -----------------------------------------------------------


class Panel:
    def __init__(self, sdk):
        self.sdk = sdk
        self.profiles = []
        self.hosts = []
        self.squads = []
        self.users = []

    async def wait_ready(self):
        for _ in range(60):
            try:
                await self.sdk.auth.get_status()
                return
            except Exception:
                await asyncio.sleep(2)
        raise ApiError("panel API did not become ready after 120 seconds")

    async def load(self):
        profiles = await self.sdk.config_profiles.get_config_profiles()
        hosts = await self.sdk.hosts.get_all_hosts()
        squads = await self.sdk.internal_squads.get_internal_squads()
        users = await self.sdk.users.get_all_users(start=0, size=1000)
        self.profiles = list(profiles.config_profiles)
        self.hosts = list(hosts)
        self.squads = list(squads.internal_squads)
        self.users = list(users.users)

    async def create_profile(self, name, config):
        result = await self.sdk.config_profiles.create_config_profile(
            CreateConfigProfileRequestDto(name=name, config=config)
        )
        self.profiles.append(result)
        return result

    async def sync_profile(self, profile, config):
        if profile.config == config:
            return profile
        result = await self.sdk.config_profiles.update_config_profile(
            UpdateConfigProfileRequestDto(
                uuid=profile.uuid, name=profile.name, config=config
            )
        )
        replace_by_uuid(self.profiles, result)
        return result

    async def delete_host(self, host):
        try:
            await self.sdk.hosts.delete_host(host.uuid)
        except Exception as error:
            warn(f"could not delete host {host.remark!r}: {error}")
            return
        self.hosts.remove(host)

    async def ensure_host(self, profile, inbound, domain, port, path):
        inbound_dto = CreateHostInboundData(
            config_profile_uuid=profile.uuid,
            config_profile_inbound_uuid=inbound.uuid,
        )
        for index, host in enumerate(self.hosts):
            if host.address == domain and host.port == port:
                current = host.inbound
                if (
                    current.config_profile_uuid != profile.uuid
                    or current.config_profile_inbound_uuid != inbound.uuid
                ):
                    result = await self.sdk.hosts.update_host(
                        UpdateHostRequestDto(uuid=host.uuid, inbound=inbound_dto)
                    )
                    self.hosts[index] = result
                return self.hosts[index]

        result = await self.sdk.hosts.create_host(
            CreateHostRequestDto(
                inbound=inbound_dto,
                remark=inbound.tag,
                address=domain,
                port=port,
                path=path,
                sni=domain,
                host="",
                fingerprint="chrome",
                is_disabled=False,
                security_layer="DEFAULT",
            )
        )
        self.hosts.append(result)
        return result

    async def ensure_profile_hosts(self, profile, domain):
        inbounds = {item.tag: item for item in profile.inbounds}
        for configured in profile.config.get("inbounds", []):
            tag = configured.get("tag")
            inbound = inbounds.get(tag)
            if inbound is None:
                raise ApiError(f"{profile.name}: inbound UUID for {tag!r} missing")
            path = (
                configured.get("streamSettings", {})
                .get("xhttpSettings", {})
                .get("path", "")
            )
            await self.ensure_host(profile, inbound, domain, configured["port"], path)

        valid = {item.uuid for item in inbounds.values()}
        stale = [
            host
            for host in self.hosts
            if _host_profile(host) == profile.uuid
            and host.inbound.config_profile_inbound_uuid not in valid
        ]
        for host in stale:
            await self.delete_host(host)

    async def ensure_squad(self, name, inbound_uuids):
        wanted = list(dict.fromkeys(inbound_uuids))
        squad = find_by_name(self.squads, name)
        if squad is None:
            result = await self.sdk.internal_squads.create_internal_squad(
                CreateInternalSquadRequestDto(name=name, inbounds=wanted)
            )
            self.squads.append(result)
            return result

        result = await self.sdk.internal_squads.get_internal_squad_by_uuid(
            squad.uuid
        )
        existing = [item.uuid for item in result.inbounds]
        missing = [uuid for uuid in wanted if uuid not in existing]
        if missing:
            result = await self.sdk.internal_squads.update_internal_squad(
                UpdateInternalSquadRequestDto(
                    uuid=squad.uuid,
                    name=squad.name,
                    inbounds=existing + missing,
                )
            )
            replace_by_uuid(self.squads, result)
            return result
        return squad

    async def service_user(self, hopping_host, connection):
        digest = hashlib.sha256(
            f"{hopping_host}-{connection['host']}".encode()
        ).hexdigest()[:24]
        username = f"hop_{digest}"
        user = next(
            (item for item in self.users if item.username == username), None
        )
        if user is None:
            result = await self.sdk.users.create_user(
                CreateUserBodyDto(
                    username=username,
                    status="ACTIVE",
                    expire_at="2099-12-31T23:59:59.000Z",
                    traffic_limit_bytes=0,
                    traffic_limit_strategy="NO_RESET",
                    active_internal_squads=[connection["squadUuid"]],
                )
            )
            user = result
            self.users.append(result)
        if not user.vless_uuid:
            raise ApiError(f"service user {username!r} has no vlessUuid")
        return user


def _host_profile(host):
    return host.inbound.config_profile_uuid


# --- basic (exit) nodes -----------------------------------------------------


async def ensure_basic_node(panel, node):
    host = node["host"]
    domain = node["domain"]
    name = f"Basic-{host}"
    profile = find_by_name(panel.profiles, name)

    if profile is None:
        inbound = reality_inbound(
            host, 443, domain, keypair(), short_ids(), random_path()
        )
        profile = await panel.create_profile(
            name, profile_config([inbound], base_outbounds(), block_rules())
        )

    config = copy.deepcopy(profile.config)
    entry = next(
        (i for i in config.get("inbounds", []) if i.get("tag") == host), None
    )
    if entry is None:
        raise ApiError(f"{name}: inbound {host!r} not found")
    if ensure_inbound_public_key(entry):
        profile = await panel.sync_profile(profile, config)

    await panel.ensure_profile_hosts(profile, domain)
    entry_uuid = inbound_uuid(profile, host)
    squad = await panel.ensure_squad(f"Bridge-{host}", [entry_uuid])

    stream = entry["streamSettings"]
    connection = {
        "host": host,
        "domain": domain,
        "squadUuid": str(squad.uuid),
        "path": stream["xhttpSettings"]["path"],
        "shortId": stream["realitySettings"]["shortIds"][0],
        "publicKey": inbound_public_key(entry),
    }
    return connection, inbound_uuids(profile)


# --- hopping (entry) nodes --------------------------------------------------


def hopping_entry_inbound(existing, host, domain):
    """Reuse the existing 443 entry inbound (keys/path preserved) or make one."""
    old = {i.get("tag"): i for i in (existing or {}).get("inbounds", [])}
    reuse = old.get(host) or old.get(f"hopping-direct-{host}")
    if reuse is not None:
        inbound = copy.deepcopy(reuse)
        inbound["tag"] = host
        inbound["port"] = 443
        ensure_inbound_public_key(inbound)
        return inbound
    return reality_inbound(host, 443, domain, keypair(), short_ids(), random_path())


async def build_hopping_config(panel, existing, host, domain, exit_connection):
    inbound = hopping_entry_inbound(existing, host, domain)
    user = await panel.service_user(host, exit_connection)
    gate = gate_outbound("gate", exit_connection, str(user.vless_uuid))
    # gate is first, so it is the default outbound; RU still exits directly.
    outbounds = [gate] + base_outbounds()
    rules = block_rules() + ru_direct_rules()
    return profile_config([inbound], outbounds, rules)


async def ensure_hopping_node(panel, node, connections):
    if not connections:
        raise ApiError(f"Hopping-{node['host']}: no exit (basic) node configured")

    host = node["host"]
    domain = node["domain"]
    name = f"Hopping-{host}"
    profile = find_by_name(panel.profiles, name)
    existing = profile.config if profile is not None else None

    config = await build_hopping_config(
        panel, existing, host, domain, connections[0]
    )
    if profile is None:
        profile = await panel.create_profile(name, config)
    else:
        profile = await panel.sync_profile(profile, config)

    await panel.ensure_profile_hosts(profile, domain)
    return inbound_uuids(profile)


async def main():
    with open(NODES_FILE, encoding="utf-8") as file:
        nodes = json.load(file)

    basic_nodes = nodes.get("basic", [])
    hopping_nodes = nodes.get("hopping", [])

    sdk = RemnawaveSDK(base_url=API_BASE_URL, token=API_TOKEN)
    panel = Panel(sdk)
    await panel.wait_ready()
    await panel.load()

    connections = []
    default_inbounds = []

    for node in basic_nodes:
        connection, inbound_uuids = await ensure_basic_node(panel, node)
        connections.append(connection)
        default_inbounds.extend(inbound_uuids)

    for node in hopping_nodes:
        default_inbounds.extend(await ensure_hopping_node(panel, node, connections))

    if default_inbounds:
        await panel.ensure_squad(DEFAULT_SQUAD_NAME, default_inbounds)


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except Exception as error:
        print(f"Remnawave bootstrap failed: {error}", file=sys.stderr)
        raise SystemExit(1)
