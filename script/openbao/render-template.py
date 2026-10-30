#!/usr/bin/env python3

import argparse
import os
import sys
import tempfile
from pathlib import Path
from string import Template

import argcomplete
import hvac
from hvac.exceptions import VaultDown
from requests.exceptions import ConnectionError, Timeout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-file", type=Path, required=True)
    parser.add_argument("--address", default=os.environ.get("BAO_ADDR"))
    parser.add_argument("--token", default=os.environ.get("BAO_TOKEN"))
    parser.add_argument("--mount", required=True)
    parser.add_argument("--template-file", type=Path, required=True)
    parser.add_argument(
        "--secret",
        nargs=3,
        action="append",
        default=[],
        metavar=("NAME", "PATH", "KEY"),
    )
    parser.add_argument(
        "--value", nargs=2, action="append", default=[], metavar=("NAME", "VALUE")
    )
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    if not args.address:
        parser.error("provide --address or BAO_ADDR")
    if not args.token:
        parser.error("provide --token or BAO_TOKEN")

    client = hvac.Client(url=args.address.strip(), token=args.token.strip(), timeout=5)
    template = Template(args.template_file.read_text())
    values = {}
    for name, value in args.value:
        values[name] = value

    secrets = {}
    try:
        for name, path, key in args.secret:
            if path not in secrets:
                result = client.secrets.kv.v2.read_secret_version(
                    mount_point=args.mount,
                    path=path,
                    raise_on_deleted_version=True,
                )
                secrets[path] = result["data"]["data"]
            value = secrets[path].get(key)
            if value is None:
                values.setdefault(name, "")
                continue
            values[name] = str(value)
    except (ConnectionError, Timeout, VaultDown):
        print(
            "OpenBao is unavailable; keeping the existing output file.", file=sys.stderr
        )
        return 0

    try:
        rendered = template.substitute(values)
    except (KeyError, ValueError):
        parser.error("template has an invalid placeholder or an undefined variable")

    args.output_file.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    temporary_file = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", dir=args.output_file.parent, delete=False
        ) as output:
            temporary_file = output.name
            output.write(rendered)
        os.replace(temporary_file, args.output_file)
    finally:
        if temporary_file is not None and os.path.exists(temporary_file):
            os.unlink(temporary_file)


if __name__ == "__main__":
    sys.exit(main())
