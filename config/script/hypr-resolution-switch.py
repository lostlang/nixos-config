#!/usr/bin/env python3

import argparse
import subprocess
import sys
from pathlib import Path

from lib.fzf import select


def main():
    hypr_dir = Path.home() / ".config/hypr"
    profiles = {}
    for path in (hypr_dir / "resolution").glob("*.lua"):
        profiles[path.stem] = path

    parser = argparse.ArgumentParser(prog="hypr-resolution-switch")
    parser.add_argument(
        "--hard", action="store_true", help="exit Hyprland instead of reloading"
    )
    parser.add_argument("mode", nargs="?", choices=profiles)
    args = parser.parse_args()

    if not profiles:
        print("no resolution profiles found", file=sys.stderr)
        return 1

    if args.mode is None:
        args.mode = select(profiles, prompt="Resolution: ")
        if args.mode is None:
            return 0

    target = profiles[args.mode]
    active = hypr_dir / "active-profile.lua"

    if not target.is_file():
        print(f"profile not found: {target}", file=sys.stderr)
        return 1

    active.unlink(missing_ok=True)
    active.symlink_to(target)
    if args.hard:
        command = ["hyprctl", "dispatch", "hl.dsp.exit()"]
    else:
        command = ["hyprctl", "reload"]

    return subprocess.run(command, check=False).returncode


if __name__ == "__main__":
    sys.exit(main())
