#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
from pathlib import Path

from lib.filesystem import clear_directory, restore_file
from lib.fzf import select


def clean_os():
    subprocess.run(["sudo", "nix-collect-garbage", "-d"], check=True)


def remove_zellij_sessions():
    result = subprocess.run(
        ["zellij", "kill-all-sessions", "-y"], capture_output=True, text=True
    )
    if result.returncode != 0 and "No active zellij sessions found." not in (
        result.stdout + result.stderr
    ):
        raise subprocess.CalledProcessError(
            result.returncode,
            result.args,
            output=result.stdout,
            stderr=result.stderr,
        )

    subprocess.run(["zellij", "delete-all-sessions", "-y"], check=True)


def remove_zellij_cache():
    cache_directory = (
        Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache") / "zellij"
    )
    clear_directory(cache_directory)


def restore_zellij_permissions():
    cache_directory = (
        Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache") / "zellij"
    )
    permissions_file = (
        Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
        / "zellij"
        / "permissions.kdl"
    )
    restore_file(permissions_file, cache_directory / "permissions.kdl")


def clean_zellij():
    remove_zellij_sessions()
    remove_zellij_cache()

    restore_zellij_permissions()


def remove_nvim_swaps():
    swap_directory = (
        Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state")
        / "nvim"
        / "swap"
    )
    clear_directory(swap_directory)


def clean_nvim():
    remove_nvim_swaps()


cleanup_functions = {"os": clean_os}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--nvim", action="store_true")
    parser.add_argument("--zellij", action="store_true")
    args = parser.parse_args()

    if args.nvim:
        cleanup_functions["nvim"] = clean_nvim
    if args.zellij:
        cleanup_functions["zellij"] = clean_zellij

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
