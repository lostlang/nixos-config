#!/usr/bin/env python3

import argparse
import argcomplete
import subprocess
import sys
from pathlib import Path

from lib.cli import help_requested
from lib.flakes import find_flake_dirs
from lib.fzf import select


def main():
    help_mode = help_requested()

    executables_parser = argparse.ArgumentParser(add_help=False)
    required_executables = [
        executables_parser.add_argument("--nix-executable"),
        executables_parser.add_argument("--fzf-executable"),
    ]
    if not help_mode:
        for option in required_executables:
            option.required = True

    dependency_parser = argparse.ArgumentParser(
        add_help=False, parents=[executables_parser]
    )
    config_dir_option = dependency_parser.add_argument("--config-dir", type=Path)
    args, _ = dependency_parser.parse_known_args()
    if not help_mode:
        config_dir_option.required = True

    flake_dirs = {}
    if args.config_dir is not None:
        flake_dirs = find_flake_dirs(system_dir=args.config_dir)

    parser = argparse.ArgumentParser(parents=[dependency_parser])
    parser.add_argument("target", nargs="?", choices=list(flake_dirs))
    parser.add_argument("update_args", nargs=argparse.REMAINDER)
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()
    update_args = args.update_args

    if not flake_dirs:
        return 0

    if len(flake_dirs) == 1:
        selected = next(iter(flake_dirs))
    else:
        selected = args.target
        if selected is None:
            selected = select(
                list(flake_dirs),
                prompt="Select flake to update: ",
                executable=args.fzf_executable,
            )
            if selected is None:
                return 0

    for flake_dir in flake_dirs[selected]:
        subprocess.run(
            [
                args.nix_executable,
                "flake",
                "update",
                "--flake",
                str(flake_dir),
                *update_args,
            ],
            check=True,
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
