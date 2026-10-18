#!/usr/bin/env python3

import argparse
import subprocess
import sys

from lib.fzf import select


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--fzf-executable", required=True)
    parser.add_argument("--nixos-rebuild-executable", required=True)
    parser.add_argument("--config-dir", required=True)
    parser.add_argument("--host", action="append", dest="hosts", required=True)
    args = parser.parse_args()

    host = select(
        ["all", *args.hosts],
        prompt="Select a VPS to update: ",
        executable=args.fzf_executable,
    )
    if host is None:
        return 0

    selected_hosts = args.hosts if host == "all" else [host]
    for selected_host in selected_hosts:
        subprocess.run(
            [
                args.nixos_rebuild_executable,
                "switch",
                "--flake",
                f"{args.config_dir}#{selected_host}",
                "--target-host",
                selected_host,
                "--use-substitutes",
                "--elevate=sudo",
            ],
            check=True,
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
