#!/usr/bin/env python3

import argparse
import subprocess
import sys
from pathlib import Path

from lib.flakes import find_flake_dirs
from lib.fzf import select


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--nix-executable", required=True)
    parser.add_argument("--fzf-executable", required=True)
    args, update_args = parser.parse_known_args()

    flake_dirs = find_flake_dirs(
        system_dir=Path.home() / ".config/nixos",
    )

    if not flake_dirs:
        return 0

    if len(flake_dirs) == 1:
        selected = next(iter(flake_dirs))
    else:
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
