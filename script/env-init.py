#!/usr/bin/env python3

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

from lib.fzf import select


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--git-executable", required=True)
    parser.add_argument("--fzf-executable", required=True)
    args = parser.parse_args()

    env_dir = Path.home() / ".config/nixos/env"
    env_names = sorted(
        path.name.removesuffix(".flake.nix") for path in env_dir.glob("*.flake.nix")
    )

    selected_env = select(
        env_names, prompt="Select environment: ", executable=args.fzf_executable
    )
    if selected_env is None:
        return 0

    flake_path = Path.cwd() / "flake.nix"
    if flake_path.is_file():
        print("The flake.nix file already exists")
    else:
        source = env_dir / f"{selected_env}.flake.nix"
        shutil.copy(source, flake_path)

    if (Path.cwd() / ".git").exists():
        subprocess.run([args.git_executable, "add", "flake.nix"], check=True)

    return 0


if __name__ == "__main__":
    sys.exit(main())
