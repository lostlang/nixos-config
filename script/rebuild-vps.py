#!/usr/bin/env python3

import argparse
import argcomplete
import ipaddress
import subprocess
import sys
from enum import StrEnum

from lib.cli import help_requested
from lib.fzf import select


class Target(StrEnum):
    ALL = "all"


def main():
    help_mode = help_requested()

    executables_parser = argparse.ArgumentParser(add_help=False)
    required_executables = [
        executables_parser.add_argument("--fzf-executable"),
        executables_parser.add_argument("--nixos-rebuild-executable"),
    ]
    if not help_mode:
        for option in required_executables:
            option.required = True

    dependency_parser = argparse.ArgumentParser(
        add_help=False, parents=[executables_parser]
    )
    required_dependencies = [
        dependency_parser.add_argument(
            "--host", action="append", dest="hosts", default=[]
        ),
    ]
    args, _ = dependency_parser.parse_known_args()
    if not help_mode:
        for option in required_dependencies:
            option.required = True

    parser = argparse.ArgumentParser(parents=[dependency_parser])
    parser.add_argument("--config-dir", required=True)
    parser.add_argument("--ip", type=ipaddress.ip_address)
    parser.add_argument("target", nargs="?", choices=[Target.ALL, *args.hosts])
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    target = args.target
    if target is None:
        target = select(
            [Target.ALL, *args.hosts],
            prompt="Select a VPS to update: ",
            executable=args.fzf_executable,
        )
        if target is None:
            return 0

    selected_hosts = args.hosts if target == Target.ALL else [target]
    for selected_host in selected_hosts:
        target_host = selected_host
        if args.ip is not None:
            target_host = str(args.ip)
        subprocess.run(
            [
                args.nixos_rebuild_executable,
                "switch",
                "--flake",
                f"{args.config_dir}#{selected_host}",
                "--target-host",
                target_host,
                "--use-substitutes",
                "--elevate=sudo",
            ],
            check=True,
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
