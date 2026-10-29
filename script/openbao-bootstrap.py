#!/usr/bin/env python3

import argparse
import base64
import json
import os
import secrets
import string
import subprocess
import sys
from enum import StrEnum
from functools import partial
from pathlib import Path

import argcomplete


class Field(StrEnum):
    DATA = "data"
    TYPE = "type"
    OPTIONS = "options"
    PASSWORD = "password"
    RANDOM = "random"


def _bao_read(path, environment, executable):
    result = subprocess.run(
        [executable, "read", "-format=json", path],
        env=environment,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        if result.returncode == 2 and result.stderr.strip().startswith(
            "No value found at "
        ):
            return None
        raise subprocess.CalledProcessError(
            result.returncode, result.args, result.stdout, result.stderr
        )

    return json.loads(result.stdout)[Field.DATA]


def _bao_write(path, data, environment, executable):
    subprocess.run(
        [executable, "write", path, "-"],
        env=environment,
        input=json.dumps(data),
        text=True,
        stdout=subprocess.DEVNULL,
        check=True,
    )


def store_credentials(username, credentials, bao_write):
    print(json.dumps(credentials), flush=True)
    bao_write(
        f"secret/data/user/{username}",
        {Field.DATA: credentials, Field.OPTIONS: {"cas": 0}},
    )


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


def provision(args, environment, init_credentials):
    bao_read = partial(
        _bao_read, environment=environment, executable=args.bao_executable
    )
    bao_write = partial(
        _bao_write, environment=environment, executable=args.bao_executable
    )

    mounts = bao_read("sys/mounts")
    if mounts is None:
        raise ValueError("Could not read OpenBao secret engine mounts.")

    engine = {Field.TYPE: "kv", Field.OPTIONS: {"version": "2"}}
    for mount, filename in args.secret_engine:
        existing = mounts.get(f"{mount}/")
        if existing is None:
            bao_write(f"sys/mounts/{mount}", engine)
            mounts[f"{mount}/"] = engine

        initial_secrets = json.loads(Path(filename).read_text())
        for path, data in initial_secrets.items():
            metadata = bao_read(f"{mount}/metadata/{path}")
            if metadata is not None and not args.force:
                continue

            version = 0
            if metadata is not None:
                version = metadata["current_version"]
            bao_write(
                f"{mount}/data/{path}",
                {
                    Field.DATA: generate_random_values(data),
                    Field.OPTIONS: {"cas": version},
                },
            )

    if mounts.get("secret/") is None:
        bao_write("sys/mounts/secret", engine)

    if init_credentials is not None:
        bao_write(
            "secret/data/bootstrap/init",
            {Field.DATA: init_credentials, Field.OPTIONS: {"cas": 0}},
        )

    for name, filename in args.policy:
        bao_write(
            f"sys/policies/acl/{name}",
            {"policy": Path(filename).read_text()},
        )

    auth_mounts = bao_read("sys/auth")
    if auth_mounts is None:
        raise ValueError("Could not read OpenBao auth mounts.")
    for auth_type in ("approle", "userpass"):
        if auth_mounts.get(f"{auth_type}/") is None:
            bao_write(f"sys/auth/{auth_type}", {Field.TYPE: auth_type})

    for username, policy in args.user:
        if not username.endswith("-vault"):
            continue

        path = f"auth/approle/role/{username}"
        bao_write(path, {"token_policies": [policy]})
        if bao_read(f"secret/metadata/user/{username}") is None:
            role = bao_read(f"{path}/role-id")
            if role is None:
                raise ValueError(f"Could not read role ID for {username}.")
            result = subprocess.run(
                [
                    args.bao_executable,
                    "write",
                    "-format=json",
                    "-f",
                    f"{path}/secret-id",
                ],
                env=environment,
                capture_output=True,
                text=True,
                check=True,
            )
            secret = json.loads(result.stdout)[Field.DATA]
            credentials = {
                "role": username,
                "role_id": role["role_id"],
                "secret_id": secret["secret_id"],
            }
            store_credentials(username, credentials, bao_write)

    for username, policy in args.user:
        if username.endswith("-vault"):
            continue

        path = f"auth/userpass/users/{username}"
        payload: dict[str, str | list[str]] = {"token_policies": [policy]}
        if bao_read(f"secret/metadata/user/{username}") is None:
            payload[Field.PASSWORD] = secrets.token_urlsafe(32)
        bao_write(path, payload)
        if Field.PASSWORD in payload:
            credentials = {
                "username": username,
                Field.PASSWORD: payload[Field.PASSWORD],
            }
            store_credentials(username, credentials, bao_write)


def main():
    executables_parser = argparse.ArgumentParser(add_help=False)
    bao_executable_env = os.environ.get("BAO_EXECUTABLE")
    executables_parser.add_argument(
        "--bao-executable",
        default=bao_executable_env,
        required=not bao_executable_env,
    )

    parser = argparse.ArgumentParser(parents=[executables_parser])
    address_env = os.environ.get("BAO_ADDR")
    parser.add_argument(
        "--address",
        default=address_env,
        required=not address_env,
    )
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

    environment = os.environ.copy()
    environment["BAO_ADDR"] = args.address
    status = subprocess.run(
        [args.bao_executable, "operator", "init", "-status"],
        env=environment,
        capture_output=True,
    )
    if status.returncode not in (0, 2):
        sys.stderr.write(status.stderr.decode())
        return status.returncode

    credentials = None
    if status.returncode == 0:
        print("OpenBao is already initialized.", file=sys.stderr)
        if args.token is None:
            raise ValueError("A token is required when OpenBao is already initialized.")
        environment["BAO_TOKEN"] = args.token
    else:
        result = subprocess.run(
            [
                args.bao_executable,
                "operator",
                "init",
                "-format=json",
                f"-recovery-shares={args.recovery_shares}",
                f"-recovery-threshold={args.recovery_threshold}",
            ],
            env=environment,
            stdout=subprocess.PIPE,
            text=True,
            check=True,
        )
        credentials = json.loads(result.stdout)
        print(json.dumps(credentials), flush=True)
        environment["BAO_TOKEN"] = credentials["root_token"]

    return provision(args, environment, credentials)


if __name__ == "__main__":
    sys.exit(main())
