#!/usr/bin/env python3

import argparse
import hashlib
import os
import sys
from pathlib import Path

from lib.find_folders import find_roots


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bubblewrap-executable", required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--sandbox-directory", type=Path)
    parser.add_argument("--runtime-path", required=True)
    parser.add_argument("--share-network", action="store_true")
    parser.add_argument("--read-only-project", action="store_true")
    parser.add_argument("--show-git", action="store_true")
    parser.add_argument("--host-env-passthrough", action="append", default=[])
    parser.add_argument("--directory", type=Path, action="append", default=[])
    parser.add_argument("--bind", nargs=2, action="append", default=[])
    parser.add_argument("--ro-bind", nargs=2, action="append", default=[])
    parser.add_argument("--setenv", nargs=2, action="append", default=[])
    parser.add_argument("--command", nargs=argparse.REMAINDER, default=[])
    args, remaining_args = parser.parse_known_args()
    sandbox_command = args.command + remaining_args

    user_home = str(Path("/home") / args.user)
    environment = {
        "HOME": user_home,
        "PATH": args.runtime_path,
        "USER": args.user,
        "LOGNAME": args.user,
        "TERM": "xterm-256color",
    }
    for name in args.host_env_passthrough:
        if name in os.environ:
            environment[name] = os.environ[name]
    environment.update(args.setenv)

    if args.sandbox_directory is None:
        parameters = (environment, sandbox_command)
        sandbox_hash = hashlib.sha256(os.fsencode(repr(parameters))).hexdigest()
        sandbox_directory = Path.home() / ".cache/sandbox" / sandbox_hash
    else:
        sandbox_directory = Path.home() / args.sandbox_directory

    directories = [
        sandbox_directory,
        sandbox_directory / user_home.lstrip("/"),
    ]
    directories += args.directory
    for directory in directories:
        directory.mkdir(parents=True, exist_ok=True)

    command = [
        args.bubblewrap_executable,
        "--clearenv",
        "--unshare-all",
        "--die-with-parent",
    ]
    if args.share_network:
        command.append("--share-net")
    command += [
        "--bind",
        str(sandbox_directory),
        "/",
        "--proc",
        "/proc",
        "--dev",
        "/dev",
        "--tmpfs",
        "/tmp",
        "--ro-bind",
        "/nix/store",
        "/nix/store",
        "--ro-bind",
        "/etc/resolv.conf",
        "/etc/resolv.conf",
    ]

    for source, target in args.bind:
        command += ["--bind", source, target]
    for source, target in args.ro_bind:
        command += ["--ro-bind", source, target]

    cwd = str(Path.cwd())
    roots = find_roots("git") or [Path.cwd()]
    project_directory = str(roots[0])
    command += [
        "--ro-bind" if args.read_only_project else "--bind",
        project_directory,
        project_directory,
        "--chdir",
        cwd,
    ]

    git_path = Path(project_directory) / ".git"
    if not args.show_git and git_path.exists():
        if git_path.is_dir():
            command += ["--tmpfs", str(git_path), "--remount-ro", str(git_path)]
        else:
            command += ["--ro-bind", "/dev/null", str(git_path)]

    for name, value in environment.items():
        command += ["--setenv", name, value]
    command += sandbox_command

    os.execv(args.bubblewrap_executable, command)


if __name__ == "__main__":
    sys.exit(main())
