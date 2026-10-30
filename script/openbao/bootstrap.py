#!/usr/bin/env python3

import argparse
import base64
import json
import os
import secrets
import string
import sys
from enum import StrEnum
from pathlib import Path

import argcomplete
import hvac


class Field(StrEnum):
    DATA = "data"
    PASSWORD = "password"
    RANDOM = "random"


def generate_random_values(value):
    if isinstance(value, list):
        result = []
        for item in value:
            result.append(generate_random_values(item))

        return result

    if not isinstance(value, dict):
        return value

    if Field.RANDOM not in value:
        result = {}
        for key, item in value.items():
            result[key] = generate_random_values(item)

        return result

    config = value[Field.RANDOM]
    length = config["length"]
    random_format = config.get("format", "ascii")
    if random_format == "hex":
        return secrets.token_hex(length)
    if random_format == "base64":
        return base64.b64encode(secrets.token_bytes(length)).decode("ascii")
    random_string = secrets.choice(string.ascii_letters)
    for _ in range(length - 1):
        random_string += secrets.choice(string.ascii_letters + string.digits)

    return random_string


def provision(args, client):
    mounts = client.sys.list_mounted_secrets_engines()[Field.DATA]
    for mount, filename in args.secret_engine:
        if f"{mount}/" not in mounts:
            client.sys.enable_secrets_engine(
                backend_type="kv", path=mount, options={"version": "2"}
            )
            mounts[f"{mount}/"] = {}

        initial_secrets = json.loads(Path(filename).read_text())
        for path, data in initial_secrets.items():
            metadata = client.read(f"{mount}/metadata/{path}")
            if metadata is not None and not args.force:
                continue

            version = 0
            if metadata is not None:
                version = metadata[Field.DATA]["current_version"]
            client.secrets.kv.v2.create_or_update_secret(
                mount_point=mount,
                path=path,
                secret=generate_random_values(data),
                cas=version,
            )

    if "secret/" not in mounts:
        client.sys.enable_secrets_engine(
            backend_type="kv", path="secret", options={"version": "2"}
        )

    for name, filename in args.policy:
        client.sys.create_or_update_policy(
            name=name,
            policy=Path(filename).read_text(),
        )

    auth_mounts = client.sys.list_auth_methods()[Field.DATA]
    for auth_type in ("approle", "userpass"):
        if auth_mounts.get(f"{auth_type}/") is None:
            client.sys.enable_auth_method(method_type=auth_type)

    for username, policy in args.user:
        if not username.endswith("-vault"):
            continue

        client.auth.approle.create_or_update_approle(
            role_name=username, token_policies=[policy]
        )
        if client.read(f"secret/metadata/user/{username}") is None:
            role = client.auth.approle.read_role_id(role_name=username)[Field.DATA]
            secret = client.auth.approle.generate_secret_id(role_name=username)[
                Field.DATA
            ]
            credentials = {
                "role_id": role["role_id"],
                "secret_id": secret["secret_id"],
            }
            print(json.dumps({"role": username, **credentials}), flush=True)
            client.secrets.kv.v2.create_or_update_secret(
                mount_point="secret",
                path=f"user/{username}",
                secret=credentials,
                cas=0,
            )

    for username, policy in args.user:
        if username.endswith("-vault"):
            continue

        payload: dict[str, str | list[str]] = {"token_policies": [policy]}
        if client.read(f"secret/metadata/user/{username}") is None:
            payload[Field.PASSWORD] = secrets.token_urlsafe(32)
        client.auth.userpass.create_or_update_user(username=username, **payload)
        if Field.PASSWORD in payload:
            credentials = {
                "username": username,
                Field.PASSWORD: payload[Field.PASSWORD],
            }
            print(json.dumps(credentials), flush=True)
            client.secrets.kv.v2.create_or_update_secret(
                mount_point="secret",
                path=f"user/{username}",
                secret=credentials,
                cas=0,
            )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--address", default=os.environ.get("BAO_ADDR"))
    parser.add_argument("--token", default=os.environ.get("BAO_TOKEN"))
    parser.add_argument("--recovery-shares", type=int, default=1)
    parser.add_argument("--recovery-threshold", type=int, default=1)
    parser.add_argument("--force", action="store_true")
    parser.add_argument(
        "--secret-engine",
        nargs=2,
        action="append",
        default=[],
        metavar=("MOUNT", "FILE"),
    )
    parser.add_argument(
        "--policy", nargs=2, action="append", default=[], metavar=("NAME", "FILE")
    )
    parser.add_argument(
        "--user", nargs=2, action="append", default=[], metavar=("USERNAME", "POLICY")
    )
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    if not args.address:
        parser.error("provide --address or BAO_ADDR")

    client = hvac.Client(url=args.address, token=args.token)
    credentials = None
    if client.sys.is_initialized():
        print("OpenBao is already initialized.", file=sys.stderr)
        if not args.token:
            parser.error("provide --token or BAO_TOKEN")
    else:
        credentials = client.sys.initialize(
            recovery_shares=args.recovery_shares,
            recovery_threshold=args.recovery_threshold,
        )
        print(json.dumps(credentials), flush=True)
        client.token = credentials["root_token"]
        mounts = client.sys.list_mounted_secrets_engines()[Field.DATA]
        if "secret/" not in mounts:
            client.sys.enable_secrets_engine(
                backend_type="kv", path="secret", options={"version": "2"}
            )
        client.secrets.kv.v2.create_or_update_secret(
            mount_point="secret",
            path="bootstrap/init",
            secret=credentials,
            cas=0,
        )

    return provision(args, client)


if __name__ == "__main__":
    sys.exit(main())
