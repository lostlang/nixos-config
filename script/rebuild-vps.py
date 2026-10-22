#!/usr/bin/env python3

import argparse
import argcomplete
import subprocess
import sys

from lib.cli import help_requested
from lib.fzf import select


def main():
    help_mode = help_requested()

    executables_parser = argparse.ArgumentParser(add_help=False)
    fzf_option = executables_parser.add_argument("--fzf-executable")
    rebuild_option = executables_parser.add_argument("--nixos-rebuild-executable")
    if not help_mode:
        fzf_option.required = True
        rebuild_option.required = True

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
    parser.add_argument("target", nargs="?", choices=["all", *args.hosts])
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    host = args.target
    if host is None:
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
