#!/usr/bin/env python3

import argparse
import os
import pwd
import sys
import tempfile
from pathlib import Path

import argcomplete
import hvac
from hvac.exceptions import VaultDown
from requests.exceptions import ConnectionError, Timeout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--address", default=os.environ.get("BAO_ADDR"))
    parser.add_argument("--role-id", default=os.environ.get("BAO_ROLE_ID"))
    parser.add_argument("--secret-id", default=os.environ.get("BAO_SECRET_ID"))
    parser.add_argument("--output-file", type=Path, required=True)
    parser.add_argument("--owner", required=True)
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    if not args.address:
        parser.error("provide --address or BAO_ADDR")
    if not args.role_id:
        parser.error("provide --role-id or BAO_ROLE_ID")
    if not args.secret_id:
        parser.error("provide --secret-id or BAO_SECRET_ID")

    client = hvac.Client(url=args.address.strip(), timeout=5)
    try:
        result = client.auth.approle.login(
            role_id=args.role_id.strip(),
            secret_id=args.secret_id.strip(),
        )
    except (ConnectionError, Timeout, VaultDown):
        if not args.output_file.is_file():
            print(
                "OpenBao is unavailable; no existing token is available.",
                file=sys.stderr,
            )
            return 1
        print("OpenBao is unavailable; keeping the existing token.", file=sys.stderr)
        return 0
    token = result["auth"]["client_token"]

    owner = pwd.getpwnam(args.owner)
    args.output_file.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chown(args.output_file.parent, owner.pw_uid, owner.pw_gid)
    os.chmod(args.output_file.parent, 0o700)
    temporary_file = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", dir=args.output_file.parent, delete=False
        ) as output:
            temporary_file = output.name
            output.write(token)
        os.chown(temporary_file, owner.pw_uid, owner.pw_gid)
        os.replace(temporary_file, args.output_file)
    finally:
        if temporary_file is not None and os.path.exists(temporary_file):
            os.unlink(temporary_file)


if __name__ == "__main__":
    sys.exit(main())
