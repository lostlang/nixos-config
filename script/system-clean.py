#!/usr/bin/env python3

import argparse
import argcomplete
from collections.abc import Callable
import os
from functools import partial
from enum import StrEnum
import subprocess
import sys
from pathlib import Path

from lib.cli import help_requested
from lib.filesystem import clear_directory, restore_file
from lib.fzf import select


class CLEANUP_MODE(StrEnum):
    ALL = "all"
    OS = "os"
    SANDBOX = "sandbox"
    NVIM = "nvim"
    ZELLIJ = "zellij"


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
    help_mode = help_requested()

    executables_parser = argparse.ArgumentParser(add_help=False)
    required_executables = [
        executables_parser.add_argument("--fzf-executable"),
        executables_parser.add_argument("--sudo-executable"),
        executables_parser.add_argument("--nix-collect-garbage-executable"),
    ]
    executables_parser.add_argument("--zellij-executable")
    if not help_mode:
        for option in required_executables:
            option.required = True

    dependency_parser = argparse.ArgumentParser(
        add_help=False, parents=[executables_parser]
    )
    dependency_parser.add_argument("--nvim", action="store_true")
    args, _ = dependency_parser.parse_known_args()

    cleanup_functions: dict[str, Callable[[], None]] = {}
    if (
        args.sudo_executable is not None
        and args.nix_collect_garbage_executable is not None
    ):
        cleanup_functions[CLEANUP_MODE.OS] = partial(
            clean_os, args.sudo_executable, args.nix_collect_garbage_executable
        )
    cleanup_functions[CLEANUP_MODE.SANDBOX] = partial(
        clear_directory, Path.home() / ".cache/sandbox"
    )
    if args.nvim:
        cleanup_functions[CLEANUP_MODE.NVIM] = clean_nvim
    if args.zellij_executable:
        cleanup_functions[CLEANUP_MODE.ZELLIJ] = partial(
            clean_zellij, args.zellij_executable
        )

    parser = argparse.ArgumentParser(parents=[dependency_parser])
    parser.add_argument(
        "mode", nargs="?", choices=[CLEANUP_MODE.ALL, *cleanup_functions]
    )
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    selected = args.mode
    if selected is None:
        selected = select(
            [CLEANUP_MODE.ALL, *cleanup_functions],
            prompt="Select what to clean: ",
            executable=args.fzf_executable,
        )
        if selected is None:
            return 0

    if selected == CLEANUP_MODE.ALL:
        selected_cleanups = cleanup_functions.values()
    else:
        selected_cleanups = [cleanup_functions[selected]]

    for cleanup in selected_cleanups:
        cleanup()

    return 0


if __name__ == "__main__":
    sys.exit(main())
