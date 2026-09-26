#!/usr/bin/env python3

import argparse
import subprocess
import sys
from pathlib import Path

from lib.fzf import select


def clean_os():
    subprocess.run(["sudo", "nix-collect-garbage", "-d"], check=True)


def clean_zellij():
    subprocess.run(["zellij", "delete-all-sessions", "-y"], check=True)


def remove_nvim_swaps():
    swap_directory = Path.home() / ".local/state/nvim/swap"
    if not swap_directory.is_dir():
        return

    for path in swap_directory.iterdir():
        if path.is_file() or path.is_symlink():
            path.unlink()


def clean_nvim():
    remove_nvim_swaps()


cleanup_functions = {"os": clean_os}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--nvim", action="store_true")
    parser.add_argument("--zellij", action="store_true")
    args = parser.parse_args()

    if args.zellij:
        cleanup_functions["zellij"] = clean_zellij
    if args.nvim:
        cleanup_functions["nvim"] = clean_nvim

    options = ["all", *cleanup_functions]
    selected = select(options, prompt="Select what to clean: ")
    if selected is None:
        return 0

    if selected == "all":
        selected_cleanups = cleanup_functions.values()
    else:
        selected_cleanups = [cleanup_functions[selected]]

    for cleanup in selected_cleanups:
        cleanup()

    return 0


if __name__ == "__main__":
    sys.exit(main())
