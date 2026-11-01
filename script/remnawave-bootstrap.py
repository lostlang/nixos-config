#!/usr/bin/env python3

import argparse
import asyncio
import base64
import hashlib
import json
import os
import secrets
import sys
from enum import StrEnum
from datetime import datetime, timezone

import argcomplete
import httpx
import hvac
from cryptography.hazmat.primitives.asymmetric.x25519 import X25519PrivateKey
from remnawave import RemnawaveSDK
from remnawave.enums import Scope, SecurityLayer
from remnawave.exceptions import ApiError
from remnawave.models import (
    CreateApiTokenRequestDto,
    CreateConfigProfileRequestDto,
    CreateHostRequestDto,
    CreateInternalSquadRequestDto,
    CreateNodeRequestDto,
    CreateUserBodyDto,
    LoginRequestDto,
    LoginResponseDto,
    RegisterRequestDto,
    UpdateConfigProfileRequestDto,
    UpdateHostRequestDto,
    UpdateInternalSquadRequestDto,
    UpdateNodeRequestDto,
    UpdateUserBodyDto,
)
from remnawave.models.hosts import CreateHostInboundData

from lib.random_values import generate_random_value


class Field(StrEnum):
    DATA = "data"
    METADATA = "metadata"
    VERSION = "version"
    API_TOKEN = "remnawave_api_token"


async def ensure_default_squad(sdk):
    response = await sdk.internal_squads.get_internal_squads()
    for squad in response.internal_squads:
        if squad.name == "Default-Squad":
            return squad.uuid
    default_squad = await sdk.internal_squads.create_internal_squad(
        CreateInternalSquadRequestDto(name="Default-Squad")
    )

    return default_squad.uuid


async def create_bridge(sdk, basic_profile, basic_name, basic_domain, hopping_name):
    inbound = None
    for item in basic_profile.inbounds:
        if item.tag == basic_name:
            inbound = item
            break
    if inbound is None:
        raise ValueError(f"Basic-{basic_name} has no inbound named {basic_name}")

    squads = await sdk.internal_squads.get_internal_squads()

    squad_name = f"Bridge-{basic_name}"
    bridge_squad = None
    for squad in squads.internal_squads:
        if squad.name == squad_name:
            bridge_squad = squad
            break
    if bridge_squad is None:
        bridge_squad = await sdk.internal_squads.create_internal_squad(
            CreateInternalSquadRequestDto(name=squad_name, inbounds=[inbound.uuid])
        )
    else:
        bridge_squad = await sdk.internal_squads.update_internal_squad(
            UpdateInternalSquadRequestDto(
                uuid=bridge_squad.uuid, inbounds=[inbound.uuid]
            )
        )

    digest = hashlib.sha256(f"{hopping_name}\0{basic_name}".encode()).hexdigest()[:24]
    username = f"hop_{digest}"
    try:
        user = await sdk.users.get_user_by_username(username)
        memberships = []
        for squad in user.active_internal_squads:
            memberships.append(squad.uuid)
        if bridge_squad.uuid not in memberships:
            memberships.append(bridge_squad.uuid)
            user = await sdk.users.update_user(
                UpdateUserBodyDto.model_validate(
                    {"id": user.id, "active_internal_squads": memberships}
                )
            )
    except ApiError as error:
        if error.status_code != 404:
            raise
        user = await sdk.users.create_user(
            CreateUserBodyDto.model_validate(
                {
                    "username": username,
                    "expire_at": datetime(
                        2099, 12, 31, 23, 59, 59, tzinfo=timezone.utc
                    ),
                    "traffic_limit_bytes": 0,
                    "active_internal_squads": [bridge_squad.uuid],
                }
            )
        )

    for item in basic_profile.config["inbounds"]:
        if item.get("tag") == basic_name:
            stream = item["streamSettings"]
            reality = stream["realitySettings"]
            return {
                "tag": "gate",
                "protocol": "vless",
                "settings": {
                    "address": basic_domain,
                    "port": 443,
                    "id": str(user.vless_uuid),
                    "encryption": "none",
                    "flow": "",
                    "level": 0,
                },
                "streamSettings": {
                    "network": "xhttp",
                    "security": "reality",
                    "xhttpSettings": {
                        "path": stream["xhttpSettings"]["path"],
                        "mode": "auto",
                    },
                    "realitySettings": {
                        "serverName": basic_domain,
                        "fingerprint": "firefox",
                        "password": reality["password"],
                        "shortId": reality["shortIds"][0],
                    },
                },
            }
    raise ValueError(f"Basic-{basic_name} has no matching inbound config")


def profile_config(name, domain, mask_port, dns_domain=None, existing=None):
    key = X25519PrivateKey.generate()
    private_key = base64.urlsafe_b64encode(key.private_bytes_raw()).decode().rstrip("=")
    public_key = (
        base64.urlsafe_b64encode(key.public_key().public_bytes_raw())
        .decode()
        .rstrip("=")
    )

    short_ids = []
    for _ in range(8):
        short_ids.append(secrets.token_hex(8))
    path = f"/{secrets.token_hex(12)}"
    if existing is not None:
        for inbound in existing.get("inbounds", []):
            if inbound.get("tag") != name:
                continue
            stream = inbound["streamSettings"]
            reality = stream["realitySettings"]
            private_key = reality["privateKey"]
            public_key = reality["password"]
            short_ids = reality["shortIds"]
            path = stream["xhttpSettings"]["path"]
            break

    config = {
        "log": {"loglevel": "warning"},
        "inbounds": [
            {
                "tag": name,
                "port": 443,
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
                    "xhttpSettings": {
                        "path": path,
                        "mode": "auto",
                    },
                    "realitySettings": {
                        "show": False,
                        "privateKey": private_key,
                        "password": public_key,
                        "shortIds": short_ids,
                        "serverNames": [domain.strip()],
                        "target": f"127.0.0.1:{mask_port}",
                        "xver": 1,
                    },
                },
            }
        ],
        "outbounds": [
            {"tag": "DIRECT", "protocol": "freedom"},
            {"tag": "BLOCK", "protocol": "blackhole"},
        ],
        "routing": {
            "domainStrategy": "IPIfNonMatch",
            "rules": [
                {"ip": ["geoip:private"], "outboundTag": "BLOCK"},
                {"domain": ["geosite:private"], "outboundTag": "BLOCK"},
                {"protocol": ["bittorrent"], "outboundTag": "BLOCK"},
            ],
        },
    }

    if dns_domain:
        config["dns"] = {
            "servers": [
                {"address": f"https://{dns_domain}/dns-query", "skipFallback": False}
            ],
            "queryStrategy": "UseIPv4",
        }
    return config


async def save_profile(sdk, name, config, existing):
    if existing is not None:
        return await sdk.config_profiles.update_config_profile(
            UpdateConfigProfileRequestDto(uuid=existing.uuid, name=name, config=config)
        )

    return await sdk.config_profiles.create_config_profile(
        CreateConfigProfileRequestDto(name=name, config=config)
    )


async def add_hopping_route(
    sdk,
    config,
    name,
    domain,
    mask_port,
    basic_name,
    basic_profile,
    basic_domain,
    port,
    country,
    existing_config,
):
    tag = f"hop-{name}-{basic_name}"
    inbound = profile_config(tag, domain, mask_port, existing=existing_config)[
        "inbounds"
    ][0]
    inbound["port"] = port
    config["inbounds"].append(inbound)
    gate = await create_bridge(sdk, basic_profile, basic_name, basic_domain, name)
    gate["tag"] = f"gate-{basic_name}"
    config["outbounds"].append(gate)
    config["routing"]["rules"].append(
        {
            "inboundTag": [tag],
            "domain": [f"domain:{country}", f"geosite:category-{country}"],
            "outboundTag": "DIRECT",
        }
    )
    config["routing"]["rules"].append({"inboundTag": [tag], "outboundTag": gate["tag"]})


async def create_basic_profiles(sdk, bao_client, nodes, mask_port, dns_domain):
    if not nodes:
        return

    profiles = await sdk.config_profiles.get_config_profiles()
    existing_profiles = {}
    for profile in profiles.config_profiles:
        existing_profiles[profile.name] = profile
    shared = bao_client.secrets.kv.v2.read_secret_version(
        mount_point="config", path="shared/remnawave", raise_on_deleted_version=True
    )[Field.DATA][Field.DATA]

    for kind, name in nodes:
        if kind != "Basic":
            continue
        profile_name = f"Basic-{name}"
        existing = existing_profiles.get(profile_name)
        domain = shared.get(f"{name}_node_domain")

        existing_config = None
        if existing is not None:
            existing_config = existing.config
        config = profile_config(
            name, domain.strip(), mask_port, dns_domain, existing_config
        )

        await save_profile(sdk, profile_name, config, existing)


async def create_hopping_profiles(
    sdk, bao_client, nodes, mask_port, port_start, direct_countries, dns_domain
):
    hopping_names = []
    basic_names = []
    for kind, name in nodes:
        if kind == "Hopping":
            hopping_names.append(name)
        elif kind == "Basic":
            basic_names.append(name)

    if not hopping_names or not basic_names:
        return

    profiles = await sdk.config_profiles.get_config_profiles()
    existing_profiles = {}
    for profile in profiles.config_profiles:
        existing_profiles[profile.name] = profile
    shared = bao_client.secrets.kv.v2.read_secret_version(
        mount_point="config", path="shared/remnawave", raise_on_deleted_version=True
    )[Field.DATA][Field.DATA]
    basic_profiles = {}
    for basic_name in basic_names:
        basic_summary = existing_profiles.get(f"Basic-{basic_name}")
        if basic_summary is None:
            raise ValueError(f"missing basic profile for {basic_name}")
        basic_domain = shared.get(f"{basic_name}_node_domain")

        basic_profile = await sdk.config_profiles.get_config_profile_by_uuid(
            str(basic_summary.uuid)
        )
        basic_profiles[basic_name] = (basic_profile, basic_domain.strip())

    for name in hopping_names:
        country = direct_countries.get(name)
        profile_name = f"Hopping-{name}"
        existing = existing_profiles.get(profile_name)
        domain = shared.get(f"{name}_node_domain")

        existing_config = None
        if existing is not None:
            existing_config = existing.config
        config = profile_config(
            name, domain.strip(), mask_port, dns_domain, existing_config
        )
        for index, basic_name in enumerate(basic_names):
            basic_profile, basic_domain = basic_profiles[basic_name]
            await add_hopping_route(
                sdk,
                config,
                name,
                domain.strip(),
                mask_port,
                basic_name,
                basic_profile,
                basic_domain,
                port_start + index,
                country,
                existing_config,
            )

        await save_profile(sdk, profile_name, config, existing)


async def create_nodes(sdk, bao_client, nodes, port):
    if not nodes:
        return

    profiles = await sdk.config_profiles.get_config_profiles()
    existing_nodes = await sdk.nodes.get_all_nodes()
    existing_by_name = {}
    for node in existing_nodes.root:
        existing_by_name[node.name] = node
    profiles_by_name = {}
    for profile in profiles.config_profiles:
        profiles_by_name[profile.name] = profile

    for kind, name in nodes:
        profile_name = f"{kind}-{name}"
        profile = profiles_by_name[profile_name]

        shared = bao_client.secrets.kv.v2.read_secret_version(
            mount_point="config", path="shared/remnawave", raise_on_deleted_version=True
        )[Field.DATA][Field.DATA]

        address = shared.get(f"{name}_node_domain")
        inbounds = []
        for inbound in profile.inbounds:
            inbounds.append(inbound.uuid)
        values = {
            "name": name,
            "address": address.strip(),
            "port": port,
            "config_profile": {
                "activeConfigProfileUuid": profile.uuid,
                "activeInbounds": inbounds,
            },
        }
        existing = existing_by_name.get(name)
        if existing is None:
            node = await sdk.nodes.create_node(
                CreateNodeRequestDto.model_validate(values)
            )
        else:
            values["uuid"] = existing.uuid
            node = await sdk.nodes.update_node(
                UpdateNodeRequestDto.model_validate(values)
            )
        existing_by_name[name] = node


async def sync_hosts(sdk, bao_client, nodes, squad_uuid):
    profiles = await sdk.config_profiles.get_config_profiles()
    profiles_by_name = {}
    for profile in profiles.config_profiles:
        profiles_by_name[profile.name] = profile
    hosts = (await sdk.hosts.get_all_hosts()).root
    hosts_by_inbound = {}
    for host in hosts:
        if host.inbound_uuid not in hosts_by_inbound:
            hosts_by_inbound[host.inbound_uuid] = host
    squads = await sdk.internal_squads.get_internal_squads()
    squad = None
    for item in squads.internal_squads:
        if item.uuid == squad_uuid:
            squad = item
            break
    if squad is None:
        raise ValueError(f"squad {squad_uuid} not found")
    existing_inbound_ids = set()
    for inbound in squad.inbounds:
        existing_inbound_ids.add(inbound.uuid)
    inbound_ids = existing_inbound_ids.copy()

    shared = bao_client.secrets.kv.v2.read_secret_version(
        mount_point="config", path="shared/remnawave", raise_on_deleted_version=True
    )[Field.DATA][Field.DATA]

    for kind, name in nodes:
        profile_name = f"{kind}-{name}"
        profile = profiles_by_name[profile_name]
        domain = shared[f"{name}_node_domain"].strip()

        inbounds_by_tag = {}
        for inbound in profile.inbounds:
            inbounds_by_tag[inbound.tag] = inbound.uuid

        for inbound in profile.config["inbounds"]:
            tag = inbound["tag"]
            inbound_uuid = inbounds_by_tag[tag]
            inbound_ids.add(inbound_uuid)
            link = CreateHostInboundData(
                config_profile_uuid=profile.uuid,
                config_profile_inbound_uuid=inbound_uuid,
            )
            values = {
                "inbound": link,
                "address": domain,
                "port": inbound["port"],
                "sni": domain,
                "path": inbound["streamSettings"]["xhttpSettings"]["path"],
            }
            existing_host = hosts_by_inbound.get(inbound_uuid)
            if existing_host is not None:
                await sdk.hosts.update_host(
                    UpdateHostRequestDto(uuid=existing_host.uuid, **values)
                )
                continue

            remark = tag
            if len(tag) > 40:
                digest = hashlib.sha256(tag.encode()).hexdigest()[:8]
                remark = f"{tag[:31]}-{digest}"
            host = await sdk.hosts.create_host(
                CreateHostRequestDto(
                    **values,
                    remark=remark,
                    host="",
                    fingerprint="firefox",
                    is_disabled=False,
                    security_layer=SecurityLayer.DEFAULT,
                )
            )
            hosts_by_inbound[inbound_uuid] = host

    if inbound_ids != existing_inbound_ids:
        await sdk.internal_squads.update_internal_squad(
            UpdateInternalSquadRequestDto(uuid=squad_uuid, inbounds=list(inbound_ids))
        )


async def create_subscription_user(sdk, username, default_squad_uuid):
    try:
        await sdk.users.get_user_by_username(username)
        return
    except ApiError as error:
        if error.status_code != 404:
            raise

    await sdk.users.create_user(
        CreateUserBodyDto.model_validate(
            {
                "username": username,
                "expire_at": datetime(2099, 12, 31, 23, 59, 59, tzinfo=timezone.utc),
                "traffic_limit_bytes": 0,
                "active_internal_squads": [default_squad_uuid],
            }
        )
    )


async def sync_node_secret(client, bao_client):
    response = await client.get("keygen")
    response.raise_for_status()
    result = response.json()["response"]
    secret_key = result.get("secretKey")

    config = bao_client.secrets.kv.v2.read_secret_version(
        mount_point="config", path="shared/remnawave", raise_on_deleted_version=True
    )[Field.DATA]
    values = config[Field.DATA]
    if values.get("secret_key") != secret_key:
        values["secret_key"] = secret_key
        bao_client.secrets.kv.v2.create_or_update_secret(
            mount_point="config",
            path="shared/remnawave",
            secret=values,
            cas=config[Field.METADATA][Field.VERSION],
        )


async def create_subscription_token(sdk, bao_client, config_path):
    config = bao_client.secrets.kv.v2.read_secret_version(
        mount_point="config", path=config_path, raise_on_deleted_version=True
    )[Field.DATA]
    values = config[Field.DATA]
    if values.get(Field.API_TOKEN):
        return

    token = await sdk.api_tokens_management.create(
        CreateApiTokenRequestDto(
            name="subscription-page",
            expires_in_days=36500,
            scopes=[
                Scope.SUBSCRIPTION_PAGE_CONFIGS_LIST,
                Scope.SUBSCRIPTION_PAGE_CONFIGS_GET,
                Scope.SUBSCRIPTIONS_SUBPAGE_CONFIG,
                Scope.SYSTEM_METADATA,
                Scope.USERS_BY_USERNAME,
            ],
        )
    )
    values[Field.API_TOKEN] = token.token
    bao_client.secrets.kv.v2.create_or_update_secret(
        mount_point="config",
        path=config_path,
        secret=values,
        cas=config[Field.METADATA][Field.VERSION],
    )


async def main():
    openbao_parser = argparse.ArgumentParser(add_help=False)
    openbao_parser.add_argument("--openbao-address", default=os.environ.get("BAO_ADDR"))
    openbao_parser.add_argument("--openbao-token", default=os.environ.get("BAO_TOKEN"))
    openbao_parser.add_argument("--openbao-secret-path", default="remnawave/admin")
    openbao_parser.add_argument("--openbao-config-path", required=True)

    parser = argparse.ArgumentParser(parents=[openbao_parser])
    parser.add_argument("--api-port", required=True, type=int)
    parser.add_argument("--username", required=True)
    parser.add_argument("--node-port", required=True, type=int)
    parser.add_argument("--mask-port", required=True, type=int)
    parser.add_argument("--hopping-port-start", required=True, type=int)
    parser.add_argument("--adguard-dns", action="store_true")
    parser.add_argument(
        "--direct-country",
        action="append",
        nargs=2,
        default=[],
        metavar=("NAME", "COUNTRY"),
    )
    parser.add_argument(
        "--node", action="append", nargs=2, default=[], metavar=("KIND", "NAME")
    )
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    if not args.openbao_address:
        parser.error("provide --openbao-address or BAO_ADDR")
    if not args.openbao_token:
        parser.error("provide --openbao-token or BAO_TOKEN")

    direct_countries = {}
    for name, country in args.direct_country:
        direct_countries[name] = country

    bao_client = hvac.Client(
        url=args.openbao_address.strip(), token=args.openbao_token.strip()
    )
    async with httpx.AsyncClient(
        base_url=f"http://127.0.0.1:{args.api_port}/api/",
        headers={
            "X-Forwarded-Proto": "https",
            "X-Forwarded-For": "127.0.0.1",
            "X-Remnawave-Client-Type": "browser",
        },
        trust_env=False,
    ) as client:
        sdk = RemnawaveSDK(client=client)
        metadata = bao_client.read(f"secret/metadata/{args.openbao_secret_path}")
        if metadata is not None:
            print("Remnawave credentials already exist in OpenBao.", file=sys.stderr)
            credentials = bao_client.secrets.kv.v2.read_secret_version(
                mount_point="secret",
                path=args.openbao_secret_path,
                raise_on_deleted_version=True,
            )[Field.DATA][Field.DATA]
        else:
            credentials = {
                "username": args.username,
                "password": generate_random_value(32),
            }
            await sdk.auth.register(RegisterRequestDto(**credentials))
            print(json.dumps(credentials), flush=True)
            bao_client.secrets.kv.v2.create_or_update_secret(
                mount_point="secret",
                path=args.openbao_secret_path,
                secret=credentials,
                cas=0,
            )

        login = await sdk.auth.login(LoginRequestDto(**credentials))
        if not isinstance(login, LoginResponseDto):
            raise TypeError("unexpected Remnawave login response")
        client.headers["Authorization"] = f"Bearer {login.access_token}"

        dns_domain = None
        if args.adguard_dns:
            domains = bao_client.secrets.kv.v2.read_secret_version(
                mount_point="config",
                path="shared/domain",
                raise_on_deleted_version=True,
            )[Field.DATA][Field.DATA]
            dns_domain = domains.get("adguardhome")
            dns_domain = dns_domain.strip()

        await sync_node_secret(client, bao_client)
        await create_subscription_token(sdk, bao_client, args.openbao_config_path)
        await create_basic_profiles(
            sdk, bao_client, args.node, args.mask_port, dns_domain
        )
        await create_hopping_profiles(
            sdk,
            bao_client,
            args.node,
            args.mask_port,
            args.hopping_port_start,
            direct_countries,
            dns_domain,
        )
        await create_nodes(sdk, bao_client, args.node, args.node_port)
        default_squad_uuid = await ensure_default_squad(sdk)
        await sync_hosts(sdk, bao_client, args.node, default_squad_uuid)
        await create_subscription_user(sdk, args.username, default_squad_uuid)

        return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
