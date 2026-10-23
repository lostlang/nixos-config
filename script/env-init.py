#!/usr/bin/env python3

import argparse
import argcomplete
import shutil
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
        executables_parser.add_argument("--git-executable"),
        executables_parser.add_argument("--fzf-executable"),
    ]
    if not help_mode:
        for option in required_executables:
            option.required = True

    dependency_parser = argparse.ArgumentParser(
        add_help=False, parents=[executables_parser]
    )
    env_dir_option = dependency_parser.add_argument("--env-dir", type=Path)
    args, _ = dependency_parser.parse_known_args()
    if not help_mode:
        env_dir_option.required = True

    env_files = {}
    if args.env_dir is not None:
        env_files = find_named_files(args.env_dir, ".flake.nix")

    parser = argparse.ArgumentParser(parents=[dependency_parser])
    parser.add_argument("target", nargs="?", choices=env_files)
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    selected_env = args.target
    if selected_env is None:
        selected_env = select(
            env_files, prompt="Select environment: ", executable=args.fzf_executable
        )
        if selected_env is None:
            return 0

    flake_path = Path.cwd() / "flake.nix"
    if flake_path.is_file():
        print("The flake.nix file already exists")
    else:
        source = env_files[selected_env]
        shutil.copy(source, flake_path)

    if (Path.cwd() / ".git").exists():
        subprocess.run([args.git_executable, "add", "flake.nix"], check=True)

    return 0


if __name__ == "__main__":
    sys.exit(main())
