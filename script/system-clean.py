#!/usr/bin/env python3

import argparse
from collections.abc import Callable
import os
from functools import partial
import subprocess
import sys
from pathlib import Path

from lib.filesystem import clear_directory, restore_file
from lib.fzf import select


def clean_os(sudo_executable, nix_collect_garbage_executable):
    subprocess.run([sudo_executable, nix_collect_garbage_executable, "-d"], check=True)


def clean_zellij(zellij_executable):
    result = subprocess.run(
        [zellij_executable, "list-sessions", "--short", "--no-formatting"],
        capture_output=True,
        text=True,
    )
    output = result.stdout + result.stderr
    if result.returncode != 0 and "No active zellij sessions found." not in output:
        raise subprocess.CalledProcessError(
            result.returncode,
            result.args,
            output=result.stdout,
            stderr=result.stderr,
        )

    if result.returncode == 0:
        current_session = os.environ.get("ZELLIJ_SESSION_NAME")
        for session in result.stdout.splitlines():
            if not session or session == current_session:
                continue
            subprocess.run(
                [zellij_executable, "delete-session", "--force", session], check=True
            )

    cache_directory = (
        Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache") / "zellij"
    )
    permissions_file = (
        Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
        / "zellij"
        / "permissions.kdl"
    )
    clear_directory(cache_directory)
    restore_file(permissions_file, cache_directory / "permissions.kdl")


def clean_nvim():
    swap_directory = (
        Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state")
        / "nvim"
        / "swap"
    )
    clear_directory(swap_directory)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--fzf-executable", required=True)
    parser.add_argument("--sudo-executable", required=True)
    parser.add_argument("--nix-collect-garbage-executable", required=True)
    parser.add_argument("--nvim", action="store_true")
    parser.add_argument("--zellij-executable")
    args = parser.parse_args()

    cleanup_functions: dict[str, Callable[[], None]] = {
        "os": partial(
            clean_os, args.sudo_executable, args.nix_collect_garbage_executable
        ),
        "sandbox": partial(clear_directory, Path.home() / ".cache/sandbox"),
    }
    if args.nvim:
        cleanup_functions["nvim"] = clean_nvim
    if args.zellij_executable:
        cleanup_functions["zellij"] = partial(clean_zellij, args.zellij_executable)

    options = ["all", *cleanup_functions]
    selected = select(
        options, prompt="Select what to clean: ", executable=args.fzf_executable
    )
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
