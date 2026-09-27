#!/usr/bin/env python3

import subprocess
import sys
from pathlib import Path

from lib.fzf import select


def is_flake(flake_dir):
    result = subprocess.run(
        [
            "nix",
            "flake",
            "metadata",
            "--no-write-lock-file",
            str(flake_dir),
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )

    return result.returncode == 0


def main():
    system_dir = Path.home() / ".config/nixos"
    system_dir = system_dir.resolve()
    system_dirs = [system_dir, system_dir / "config"]

    current_dir = Path.cwd().resolve()

    flake_dirs = {}

    existing_system_dirs = [
        flake_dir for flake_dir in system_dirs if is_flake(flake_dir)
    ]
    if existing_system_dirs:
        flake_dirs["system"] = existing_system_dirs

    if not current_dir.is_relative_to(system_dir) and is_flake(current_dir):
        flake_dirs["current"] = [current_dir]

    if not flake_dirs:
        return 0

    if len(flake_dirs) == 1:
        selected = next(iter(flake_dirs))
    else:
        selected = select(list(flake_dirs), prompt="Select flake to update: ")
        if selected is None:
            return 0

    for flake_dir in flake_dirs[selected]:
        subprocess.run(
            [
                "nix",
                "flake",
                "update",
                "--flake",
                str(flake_dir),
                *sys.argv[1:],
            ],
            check=True,
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
