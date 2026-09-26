#!/usr/bin/env python3

import shutil
import subprocess
import sys
from pathlib import Path

from lib.fzf import select


def main():
    env_dir = Path.home() / ".config/nixos/env"
    env_names = sorted(
        path.name.removesuffix(".flake.nix") for path in env_dir.glob("*.flake.nix")
    )

    selected_env = select(env_names, prompt="Select environment: ")
    if selected_env is None:
        return 0

    flake_path = Path.cwd() / "flake.nix"
    if flake_path.is_file():
        print("The flake.nix file already exists")
    else:
        source = env_dir / f"{selected_env}.flake.nix"
        shutil.copy(source, flake_path)

    if (Path.cwd() / ".git").is_dir():
        subprocess.run(["git", "add", "flake.nix"], check=True)

    return 0


if __name__ == "__main__":
    sys.exit(main())
