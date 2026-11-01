#!/usr/bin/env python3

import argparse
import os
import sys
from enum import StrEnum

import argcomplete
import hvac
from argon2 import PasswordHasher
from argon2.exceptions import HashingError
from hvac.exceptions import InvalidPath, VaultError
from requests.exceptions import RequestException

from lib.random_values import RandomFormat, generate_random_value


class Field(StrEnum):
    DATA = "data"
    METADATA = "metadata"
    VERSION = "version"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--address", default=os.environ.get("BAO_ADDR"))
    parser.add_argument("--token", default=os.environ.get("BAO_TOKEN"))
    parser.add_argument(
        "--secret", nargs=3, required=True, metavar=("MOUNT", "PATH", "KEY")
    )
    parser.add_argument("--hash-secret", nargs=3, metavar=("MOUNT", "PATH", "KEY"))
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--length", type=int, default=64)
    parser.add_argument(
        "--format",
        type=RandomFormat,
        choices=list(RandomFormat),
        default=RandomFormat.ASCII,
    )
    parser.add_argument("--hash-time-cost", type=int, default=3)
    parser.add_argument("--hash-memory-cost", type=int, default=65540)
    parser.add_argument("--hash-parallelism", type=int, default=4)
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    if not args.address:
        parser.error("provide --address or BAO_ADDR")
    if not args.token:
        parser.error("provide --token or BAO_TOKEN")
    destinations = [args.secret]
    if args.hash_secret:
        destinations.append(args.hash_secret)

    client = hvac.Client(url=args.address.strip(), token=args.token.strip())
    documents = {}
    try:
        for mount, path, key in destinations:
            location = (mount, path)
            if location in documents:
                continue
            data = {}
            version = 0
            try:
                result = client.secrets.kv.v2.read_secret_version(
                    mount_point=mount, path=path, raise_on_deleted_version=True
                )[Field.DATA]
                data = result[Field.DATA]
                version = result[Field.METADATA][Field.VERSION]
            except InvalidPath:
                pass
            documents[location] = (data, version)

        mount, path, key = args.secret
        data, version = documents[(mount, path)]
        value = data.get(key)
        create_value = args.force or value is None
        if create_value:
            value = generate_random_value(args.length, args.format)
        if not isinstance(value, str) or not value.strip():
            parser.error("stored secret must be a nonempty string")
        if create_value:
            data[key] = value

        if args.hash_secret:
            hasher = PasswordHasher(
                time_cost=args.hash_time_cost,
                memory_cost=args.hash_memory_cost,
                parallelism=args.hash_parallelism,
            )
            hash_mount, hash_path, hash_key = args.hash_secret
            hash_data, hash_version = documents[(hash_mount, hash_path)]
            hash_data[hash_key] = hasher.hash(value)

        for (mount, path), (data, version) in documents.items():
            if not create_value and (mount, path) == tuple(args.secret[:2]):
                if not args.hash_secret or (mount, path) != tuple(args.hash_secret[:2]):
                    continue
            client.secrets.kv.v2.create_or_update_secret(
                mount_point=mount, path=path, secret=data, cas=version
            )
    except (VaultError, RequestException, OSError, HashingError):
        print(
            "Secret generation failed; check OpenBao access and retry. "
            "Retry without --force to reuse any value already stored in OpenBao.",
            file=sys.stderr,
        )
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
