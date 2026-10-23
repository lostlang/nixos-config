#!/usr/bin/env python3

import argparse
import argcomplete
import subprocess
import sys
from pathlib import Path

from lib.cli import help_requested
from lib.filesystem import find_named_files
from lib.fzf import select


def main():
    help_mode = help_requested()

    executables_parser = argparse.ArgumentParser(add_help=False)
    required_executables = [
        executables_parser.add_argument("--fzf-executable"),
        executables_parser.add_argument("--hyprctl-executable"),
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

    profiles = {}
    if args.config_dir is not None:
        profiles = find_named_files(args.config_dir / "resolution", ".lua")

    parser = argparse.ArgumentParser(parents=[dependency_parser])
    parser.add_argument(
        "--hard", action="store_true", help="exit Hyprland instead of reloading"
    )
    parser.add_argument("mode", nargs="?", choices=profiles)
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    if not profiles:
        print("no resolution profiles found", file=sys.stderr)
        return 1

    if args.mode is None:
        args.mode = select(
            profiles, prompt="Resolution: ", executable=args.fzf_executable
        )
        if args.mode is None:
            return 0

    target = profiles[args.mode]
    active = args.config_dir / "active-profile.lua"

    if not target.is_file():
        print(f"profile not found: {target}", file=sys.stderr)
        return 1

    active.unlink(missing_ok=True)
    active.symlink_to(target)
    if args.hard:
        command = [args.hyprctl_executable, "dispatch", "hl.dsp.exit()"]
    else:
        command = [args.hyprctl_executable, "reload"]

    return subprocess.run(command, check=False).returncode


if __name__ == "__main__":
    sys.exit(main())
