#!/usr/bin/env python3
"""Set up Remnawave exits, hopping entries, and their shared subscription squad."""

import argparse
import asyncio
import base64
import contextlib
import copy
import hashlib
import json
import re
import secrets
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from uuid import UUID

import httpx
from cryptography.hazmat.primitives.asymmetric.x25519 import X25519PrivateKey
from pydantic import ValidationError
from remnawave import RemnawaveSDK
from remnawave.enums import SecurityLayer, TrafficLimitStrategy, UserStatus
from remnawave.exceptions import ApiError as SDKError
from remnawave.models import (
    CreateConfigProfileRequestDto,
    CreateHostRequestDto,
    CreateInternalSquadRequestDto,
    CreateUserRequestDto,
    UpdateConfigProfileRequestDto,
    UpdateHostRequestDto,
    UpdateInternalSquadRequestDto,
    UpdateUserRequestDto,
)
from remnawave.models.hosts import CreateHostInboundData

BRIDGE_USER_EXPIRY = datetime(2099, 12, 31, 23, 59, 59, tzinfo=timezone.utc)


class ApiError(RuntimeError):
    def __init__(self, message, status=None):
        super().__init__(message)
        self.status = status


class ConfigError(ValueError):
    """An existing Xray configuration cannot be updated safely."""


@dataclass(frozen=True)
class BridgeConnection:
    host: str
    domain: str
    squad_uuid: UUID
    path: str
    short_id: str
    public_key: str


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--api-port", required=True, type=port_number)
    parser.add_argument("--mask-port", required=True, type=port_number)
    parser.add_argument("--nodes-file", required=True, type=Path)
    parser.add_argument("--api-token-file", required=True, type=Path)
    parser.add_argument("--adguard-domain-file", type=Path)
    args = parser.parse_args(argv)

    try:
        token = args.api_token_file.read_text(encoding="utf-8").strip()
        if not token or "\n" in token or "\r" in token:
            raise ValueError(
                "--api-token-file must contain a nonempty single-line token"
            )
        nodes = load_nodes(args.nodes_file)
        adguard_domain = ""
        if args.adguard_domain_file is not None:
            adguard_domain = args.adguard_domain_file.read_text(
                encoding="utf-8"
            ).strip()
            if adguard_domain:
                validate_domain(adguard_domain)
        if not nodes["basic"] and not nodes["hopping"]:
            log("no nodes configured")
            return 0

        async def run():
            async with panel_sdk(args.api_port, token) as sdk:
                await bootstrap(Panel(sdk), nodes, args.mask_port, adguard_domain)

        asyncio.run(run())
    except ValidationError:
        print("Remnawave bootstrap failed: invalid SDK request fields", file=sys.stderr)
        return 1
    except (ApiError, OSError, ValueError, KeyError, TypeError) as error:
        print(f"Remnawave bootstrap failed: {error}", file=sys.stderr)
        return 1
    return 0


async def bootstrap(panel, nodes, mask_port, adguard_domain):
    await panel.load()
    first_exit = None
    default_inbounds = []

    for node in nodes["basic"]:
        connection, inbounds = await ensure_basic(
            panel, node, mask_port, adguard_domain
        )
        if first_exit is None:
            first_exit = connection
        default_inbounds.extend(inbounds)

    # All hopping entries connect through the first configured basic exit.
    for node in nodes["hopping"]:
        profile, _ = await ensure_node(
            panel, node, mask_port, adguard_domain, exit_connection=first_exit
        )
        default_inbounds.extend(uuid_list(profile.inbounds))

    if default_inbounds:
        await panel.ensure_squad("Default-Squad", default_inbounds)
    log("complete")


async def ensure_basic(panel, node, mask_port, adguard_domain):
    """Prepare an exit while keeping its credentials and custom routing."""
    host, domain = node["host"], node["domain"]
    profile, inbound = await ensure_node(panel, node, mask_port, adguard_domain)
    entry = next(item for item in profile.inbounds if item.tag == host)
    squad = await panel.ensure_squad(f"Bridge-{host}", [entry.uuid])
    stream = inbound["streamSettings"]
    connection = BridgeConnection(
        host=host,
        domain=domain,
        squad_uuid=squad.uuid,
        path=stream["xhttpSettings"]["path"],
        short_id=stream["realitySettings"]["shortIds"][0],
        public_key=stream["realitySettings"]["password"],
    )
    return connection, uuid_list(profile.inbounds)


async def ensure_node(panel, node, mask_port, adguard_domain, *, exit_connection=None):
    """Save a node's profile and hosts, adding a bridge for hopping entries."""
    host, domain = node["host"], node["domain"]
    kind = "Hopping" if exit_connection is not None else "Basic"
    name = f"{kind}-{host}"
    existing_profile = await panel.get_profile(name)
    existing_config = existing_profile.config if existing_profile else None
    inbound = reality_inbound(existing_config, host, domain, mask_port)

    gate = None
    if exit_connection is not None:
        vless_uuid = await panel.ensure_bridge_user(
            host, exit_connection, existing_profile
        )
        gate = gate_outbound(exit_connection, vless_uuid)

    config = profile_config(inbound, adguard_domain, gate, existing=existing_config)
    profile = await panel.save_profile(name, config, existing_profile)
    await panel.ensure_hosts(profile, domain)
    return profile, inbound


def port_number(value):
    port = int(value)
    if not 1 <= port <= 65535:
        raise argparse.ArgumentTypeError("port must be between 1 and 65535")
    return port


def validate_domain(domain):
    message = "expected a DNS hostname without a scheme, port or path"
    if not isinstance(domain, str) or len(domain) > 253:
        raise ValueError(message)
    for label in domain.split("."):
        if not re.fullmatch(r"[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?", label):
            raise ValueError(message)


def load_nodes(path):
    nodes = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(nodes, dict):
        raise ValueError("--nodes-file must contain an object with basic/hopping lists")

    seen_hosts = set()
    seen_domains = set()
    for kind in ("basic", "hopping"):
        nodes.setdefault(kind, [])
        if not isinstance(nodes[kind], list):
            raise ValueError(f"--nodes-file: {kind} must be a list")
        for node in nodes[kind]:
            if not isinstance(node, dict) or not isinstance(node.get("host"), str):
                raise ValueError(f"--nodes-file: invalid {kind} node")
            host = node["host"]
            if not re.fullmatch(r"[A-Za-z0-9_-]{1,22}", host):
                raise ValueError(
                    "node names must be 1–22 letters, digits, underscores or hyphens"
                )
            validate_domain(node.get("domain"))
            domain = node["domain"].lower()
            if host in seen_hosts or domain in seen_domains:
                raise ValueError("--nodes-file: duplicate node name or domain")
            seen_hosts.add(host)
            seen_domains.add(domain)

    if nodes["hopping"] and not nodes["basic"]:
        raise ValueError("hopping nodes require at least one basic exit node")
    return nodes


def log(message):
    print(f"Remnawave bootstrap: {message}", flush=True)


async def check_response(response):
    # Check status before the SDK tries to parse an error response's body.
    response.raise_for_status()


@contextlib.asynccontextmanager
async def panel_sdk(port, token, *, transport=None):
    # Supply the SDK's client so local traffic ignores proxy environment variables.
    async with httpx.AsyncClient(
        base_url=f"http://127.0.0.1:{port}/api/",
        headers={
            "Authorization": (
                token if token.startswith("Bearer ") else f"Bearer {token}"
            ),
            "Accept": "application/json",
            "X-Forwarded-Proto": "https",
            "X-Forwarded-For": "127.0.0.1",
        },
        timeout=15,
        trust_env=False,
        follow_redirects=False,
        event_hooks={"response": [check_response]},
        transport=transport,
    ) as client:
        yield RemnawaveSDK(client=client)


async def sdk_call(operation, *args, timeout=15, **kwargs):
    """Use SDK validation/serialization, keeping credentials out of error logs."""
    name = operation.__name__
    try:
        async with asyncio.timeout(timeout):
            return await operation(*args, **kwargs)
    except (SDKError, httpx.HTTPStatusError) as error:
        if isinstance(error, httpx.HTTPStatusError):
            status = error.response.status_code
        else:
            status = error.status_code or None
        hint = {
            400: "check the request fields and panel version",
            401: "check --api-token-file",
            403: "check API token permissions",
            404: "resource or API endpoint not found",
        }.get(status, "check the panel log")
        raise ApiError(f"{name}: HTTP {status}; {hint}", status) from None
    except (httpx.RequestError, TimeoutError) as error:
        raise ApiError(f"{name}: connection failed ({type(error).__name__})") from None
    except ValueError:
        # SDK/Pydantic errors may include input values containing private keys.
        raise ApiError(
            f"{name}: invalid API response; check the panel/SDK versions", 422
        ) from None


async def wait_ready(sdk, timeout=120):
    deadline = time.monotonic() + timeout
    last_error = None
    while (remaining := deadline - time.monotonic()) > 0:
        try:
            return await sdk_call(
                sdk.config_profiles.get_config_profiles, timeout=min(10, remaining)
            )
        except ApiError as error:
            if (
                error.status is not None
                and error.status not in (408, 429)
                and error.status < 500
            ):
                raise
            last_error = error
            retry_delay = min(2, max(0, deadline - time.monotonic()))
            await asyncio.sleep(retry_delay)
    raise ApiError(f"API not ready after {timeout}s: {last_error}")


def find_named(items, name):
    matches = [item for item in items if item.name == name]
    if len(matches) > 1:
        raise ApiError(f"multiple objects named {name!r}; resolve the duplicates first")
    return matches[0] if matches else None


def uuid_list(items):
    return list(dict.fromkeys(item.uuid for item in items))


def changed_fields(current, wanted):
    return {
        name: value for name, value in wanted.items() if getattr(current, name) != value
    }


class Panel:
    """Find and reconcile the panel objects managed by this bootstrap."""

    def __init__(self, sdk: RemnawaveSDK):
        self.sdk = sdk
        self.profiles = []
        self.hosts = []
        self.squads = []

    async def load(self):
        self.profiles = (await wait_ready(self.sdk)).config_profiles
        self.hosts = (await sdk_call(self.sdk.hosts.get_all_hosts)).root
        self.squads = (
            await sdk_call(self.sdk.internal_squads.get_internal_squads)
        ).internal_squads

    async def get_profile(self, name):
        profile = find_named(self.profiles, name)
        if profile is None:
            return None
        # List responses may contain only metadata; edits need the complete config.
        return await sdk_call(
            self.sdk.config_profiles.get_config_profile_by_uuid, str(profile.uuid)
        )

    async def save_profile(self, name, config, existing):
        if existing is not None and existing.config == config:
            return existing
        if existing is not None:
            result = await sdk_call(
                self.sdk.config_profiles.update_config_profile,
                UpdateConfigProfileRequestDto(
                    uuid=existing.uuid, name=name, config=config
                ),
            )
        else:
            result = await sdk_call(
                self.sdk.config_profiles.create_config_profile,
                CreateConfigProfileRequestDto(name=name, config=config),
            )
        self.profiles = [item for item in self.profiles if item.uuid != result.uuid]
        self.profiles.append(result)
        log(f"{'updated' if existing else 'created'} profile {name}")
        return result

    def find_host(self, profile, inbound_uuid, tag, domain, port):
        matches = [host for host in self.hosts if host.inbound_uuid == inbound_uuid]
        if not matches:
            # Reuse only orphaned hosts; a live inbound must keep its own host.
            active_inbounds = {inbound.uuid for inbound in profile.inbounds}
            managed_remarks = (tag, f"hopping-direct-{tag}")
            matches = [
                host
                for host in self.hosts
                if host.inbound.config_profile_uuid == profile.uuid
                and host.inbound_uuid not in active_inbounds
                and host.port == port
                and (host.address == domain or host.remark in managed_remarks)
            ]
        if len(matches) > 1:
            raise ApiError(f"{profile.name}: multiple hosts for inbound {tag!r}")
        return matches[0] if matches else None

    async def ensure_hosts(self, profile, domain):
        inbound_ids = {inbound.tag: inbound.uuid for inbound in profile.inbounds}
        for inbound in profile.config["inbounds"]:
            tag = inbound["tag"]
            if tag not in inbound_ids:
                raise ApiError(f"{profile.name}: inbound {tag!r} has no UUID")
            inbound_uuid = inbound_ids[tag]
            port = inbound["port"]
            current = self.find_host(profile, inbound_uuid, tag, domain, port)
            stream = inbound.get("streamSettings", {})
            desired = {
                "address": domain,
                "port": port,
                "path": stream.get("xhttpSettings", {}).get("path", ""),
                "sni": domain,
            }
            link = CreateHostInboundData(
                config_profile_uuid=profile.uuid,
                config_profile_inbound_uuid=inbound_uuid,
            )
            if current is None:
                result = await sdk_call(
                    self.sdk.hosts.create_host,
                    CreateHostRequestDto(
                        **desired,
                        inbound=link,
                        remark=tag,
                        host="",
                        fingerprint="chrome",
                        is_disabled=False,
                        security_layer=SecurityLayer.DEFAULT,
                    ),
                )
            else:
                changes = changed_fields(current, desired)
                if (
                    current.inbound.config_profile_uuid != profile.uuid
                    or current.inbound_uuid != inbound_uuid
                ):
                    changes["inbound"] = link
                if not changes:
                    continue
                result = await sdk_call(
                    self.sdk.hosts.update_host,
                    UpdateHostRequestDto(uuid=current.uuid, **changes),
                )
                self.hosts.remove(current)
            self.hosts.append(result)
            log(f"{'updated' if current else 'created'} host for {profile.name}/{tag}")

    async def ensure_squad(self, name, desired):
        current = find_named(self.squads, name)
        existing = []
        if current is not None:
            current = await sdk_call(
                self.sdk.internal_squads.get_internal_squad_by_uuid, str(current.uuid)
            )
            existing = uuid_list(current.inbounds)
        merged = list(dict.fromkeys(existing + desired))
        if current is not None and set(merged) == set(existing):
            return current
        if current is not None:
            result = await sdk_call(
                self.sdk.internal_squads.update_internal_squad,
                UpdateInternalSquadRequestDto(
                    uuid=current.uuid, name=name, inbounds=merged
                ),
            )
        else:
            result = await sdk_call(
                self.sdk.internal_squads.create_internal_squad,
                CreateInternalSquadRequestDto(name=name, inbounds=merged),
            )
        self.squads = [item for item in self.squads if item.uuid != result.uuid]
        self.squads.append(result)
        log(f"{'updated' if current else 'created'} squad {name}")
        return result

    async def get_user(self, username):
        try:
            return await sdk_call(self.sdk.users.get_user_by_username, username)
        except ApiError as error:
            if error.status != 404:
                raise
            return None

    async def ensure_bridge_user(self, host, connection, existing_profile=None):
        """Keep one permanent bridge user per entry/exit pair."""
        gate = {}
        if existing_profile is not None:
            gate = existing_gate(existing_profile.config, host)
        # NUL cannot occur in a node name, unlike the old hyphen separator.
        digest = hashlib.sha256(f"{host}\0{connection.host}".encode()).hexdigest()[:24]
        username = f"hop_v2_{digest}"
        user = await self.get_user(username)
        if user is None and existing_profile is not None:
            legacy_digest = hashlib.sha256(
                f"{host}-{connection.host}".encode()
            ).hexdigest()[:24]
            legacy_user = await self.get_user(f"hop_{legacy_digest}")
            # Reuse a legacy account only when this profile already uses it.
            gate_user_id = gate.get("settings", {}).get("id")
            if legacy_user is not None and gate_user_id == str(legacy_user.vless_uuid):
                user = legacy_user
        desired = {
            "status": UserStatus.ACTIVE,
            "traffic_limit_bytes": 0,
            "traffic_limit_strategy": TrafficLimitStrategy.NO_RESET,
        }
        if user is None:
            user = await sdk_call(
                self.sdk.users.create_user,
                CreateUserRequestDto(
                    **desired,
                    username=username,
                    expire_at=BRIDGE_USER_EXPIRY,
                    active_internal_squads=[connection.squad_uuid],
                ),
            )
            log(f"created bridge user for {host}")
            return str(user.vless_uuid)

        changes = changed_fields(user, desired)
        squads = uuid_list(user.active_internal_squads)
        if connection.squad_uuid not in squads:
            changes["active_internal_squads"] = squads + [connection.squad_uuid]
        if user.expire_at < BRIDGE_USER_EXPIRY:
            changes["expire_at"] = BRIDGE_USER_EXPIRY
        if changes:
            user = await sdk_call(
                self.sdk.users.update_user,
                UpdateUserRequestDto(uuid=user.uuid, **changes),
            )
            log(f"updated bridge user for {host}")
        return str(user.vless_uuid)


def encode_key(value):
    return base64.urlsafe_b64encode(value).decode().rstrip("=")


def public_key(private):
    try:
        raw = base64.b64decode(
            private + "=" * (-len(private) % 4), altchars=b"-_", validate=True
        )
        key = X25519PrivateKey.from_private_bytes(raw)
    except (ValueError, TypeError) as error:
        raise ConfigError(
            "invalid existing Reality private key; refusing to replace it"
        ) from error
    return encode_key(key.public_key().public_bytes_raw())


def new_reality_inbound():
    """Generate credentials only when creating a new profile."""
    private_key = X25519PrivateKey.generate().private_bytes_raw()
    return {
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
            "xhttpSettings": {"path": f"/{secrets.token_hex(12)}", "mode": "auto"},
            "realitySettings": {
                "show": False,
                "privateKey": encode_key(private_key),
                "shortIds": [secrets.token_hex(8) for _ in range(8)],
            },
        },
    }


def existing_inbound(config, host):
    inbounds = config.get("inbounds", [])
    if not isinstance(inbounds, list) or any(
        not isinstance(inbound, dict) for inbound in inbounds
    ):
        raise ConfigError(f"{host}: expected a list of inbound objects")
    # Prefer the current tag over the legacy hopping tag.
    for tag in (host, f"hopping-direct-{host}"):
        matches = [inbound for inbound in inbounds if inbound.get("tag") == tag]
        if len(matches) > 1:
            raise ConfigError(f"{host}: multiple inbounds tagged {tag!r}")
        if matches:
            return matches[0]
    raise ConfigError(
        f"{host}: managed inbound missing; refusing to rotate credentials"
    )


def reality_inbound(existing, host, domain, mask_port):
    """Update the address and derived key without changing credentials."""
    if existing is None:
        inbound = new_reality_inbound()
    else:
        inbound = copy.deepcopy(existing_inbound(existing, host))

    stream = inbound.get("streamSettings")
    if (
        inbound.get("protocol") != "vless"
        or not isinstance(stream, dict)
        or stream.get("network") != "xhttp"
        or stream.get("security") != "reality"
    ):
        raise ConfigError(f"{host}: expected VLESS/XHTTP/Reality")

    reality = stream.get("realitySettings")
    xhttp = stream.get("xhttpSettings")
    if not isinstance(reality, dict) or not isinstance(xhttp, dict):
        raise ConfigError(f"{host}: expected Reality and XHTTP settings objects")

    short_ids = reality.get("shortIds")
    if (
        not isinstance(short_ids, list)
        or not short_ids
        or any(not isinstance(short_id, str) for short_id in short_ids)
    ):
        raise ConfigError(
            f"{host}: Reality shortIds must be a nonempty list of strings"
        )
    if not isinstance(xhttp.get("path"), str) or not xhttp["path"]:
        raise ConfigError(f"{host}: XHTTP path must be a nonempty string")

    reality.update(
        password=public_key(reality.get("privateKey")),
        serverNames=[domain],
        target=f"127.0.0.1:{mask_port}",
        xver=1,
    )
    if "publicKey" in reality:
        reality["publicKey"] = reality["password"]
    inbound.update(tag=host, port=443)
    return inbound


def existing_gate(config, host):
    """Find and validate the managed gate before changing its profile or user."""
    outbounds = config.get("outbounds", [])
    if not isinstance(outbounds, list) or any(
        not isinstance(outbound, dict) for outbound in outbounds
    ):
        raise ConfigError(f"{host}: expected a list of outbound objects")
    gates = [outbound for outbound in outbounds if outbound.get("tag") == "gate"]
    if len(gates) > 1:
        raise ConfigError(f"{host}: multiple outbounds tagged 'gate'")
    if not gates:
        return {}

    gate = gates[0]
    for key in ("settings", "streamSettings"):
        if not isinstance(gate.get(key, {}), dict):
            raise ConfigError(f"{host}: gate {key} must be an object")

    stream = gate.get("streamSettings", {})
    for key in ("xhttpSettings", "realitySettings"):
        if not isinstance(stream.get(key, {}), dict):
            raise ConfigError(f"{host}: gate streamSettings.{key} must be an object")
    return gate


def merge_managed_config(current, desired):
    """Replace managed values while preserving unrelated nested settings."""
    merged = copy.deepcopy(current)
    for key, value in desired.items():
        if isinstance(value, dict):
            merged[key] = merge_managed_config(current.get(key, {}), value)
        else:
            merged[key] = copy.deepcopy(value)
    return merged


def profile_config(inbound, adguard_domain, gate=None, *, existing=None):
    """Apply defaults to new profiles; update only managed parts of existing ones."""
    if existing is not None:
        config = copy.deepcopy(existing)
        current = existing_inbound(config, inbound["tag"])
        config["inbounds"][config["inbounds"].index(current)] = inbound
        if gate is not None:
            current_gate = existing_gate(config, inbound["tag"])
            merged_gate = merge_managed_config(current_gate, gate)
            # The managed gate stays the default; custom outbounds keep their order.
            other_outbounds = [
                outbound
                for outbound in config.get("outbounds", [])
                if outbound.get("tag") != "gate"
            ]
            config["outbounds"] = [merged_gate, *other_outbounds]
        return config

    outbounds = [
        {"tag": "DIRECT", "protocol": "freedom"},
        {"tag": "BLOCK", "protocol": "blackhole"},
    ]
    rules = [
        {"ip": ["geoip:private"], "outboundTag": "BLOCK"},
        {"domain": ["geosite:private"], "outboundTag": "BLOCK"},
        {"protocol": ["bittorrent"], "outboundTag": "BLOCK"},
    ]
    if gate is not None:
        outbounds.insert(0, gate)
        rules += [
            {"domain": ["geosite:category-ru"], "outboundTag": "DIRECT"},
            {"ip": ["geoip:ru"], "outboundTag": "DIRECT"},
        ]
    config = {
        "log": {"loglevel": "warning"},
        "inbounds": [inbound],
        "outbounds": outbounds,
        "routing": {"domainStrategy": "IPIfNonMatch", "rules": rules},
    }
    if adguard_domain:
        config["dns"] = {
            "servers": [
                {
                    "address": f"https://{adguard_domain}/dns-query",
                    "skipFallback": False,
                }
            ],
            "queryStrategy": "UseIPv4",
        }
    return config


def gate_outbound(connection, vless_uuid):
    return {
        "tag": "gate",
        "protocol": "vless",
        "settings": {
            "address": connection.domain,
            "port": 443,
            "id": vless_uuid,
            "encryption": "none",
            "flow": "",
            "level": 0,
        },
        "streamSettings": {
            "network": "xhttp",
            "security": "reality",
            "xhttpSettings": {"path": connection.path, "mode": "auto"},
            "realitySettings": {
                "serverName": connection.domain,
                "fingerprint": "firefox",
                "password": connection.public_key,
                "shortId": connection.short_id,
            },
        },
    }


if __name__ == "__main__":
    sys.exit(main())
