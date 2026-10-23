#!/usr/bin/env python3

import argparse
import argcomplete
import hashlib
import os
import sys
from enum import StrEnum
from pathlib import Path

from lib.find_folders import Marker, find_roots


class EnvironmentField(StrEnum):
    HOME = "HOME"
    PATH = "PATH"
    USER = "USER"
    LOGNAME = "LOGNAME"
    TERM = "TERM"
    LD_LIBRARY_PATH = "LD_LIBRARY_PATH"
    LIBRARY_PATH = "LIBRARY_PATH"
    PKG_CONFIG_PATH = "PKG_CONFIG_PATH"
    TERMINFO = "TERMINFO"
    SSL_CERT_FILE = "SSL_CERT_FILE"
    SSL_CERT_DIR = "SSL_CERT_DIR"


def main():
    executables_parser = argparse.ArgumentParser(add_help=False)
    executables_parser.add_argument("--bubblewrap-executable", required=True)

    parser = argparse.ArgumentParser(parents=[executables_parser])
    parser.add_argument("--user", required=True)
    parser.add_argument("--sandbox-directory", type=Path)
    parser.add_argument("--runtime-path", required=True)
    parser.add_argument("--library-path", default="")
    parser.add_argument("--pkg-config-path", default="")
    parser.add_argument("--ssl-cert-file")
    parser.add_argument("--ssl-cert-dir")
    parser.add_argument("--terminfo")
    parser.add_argument("--share-network", action="store_true")
    parser.add_argument("--read-only-project", action="store_true")
    parser.add_argument("--show-git", action="store_true")
    parser.add_argument("--host-env-passthrough", action="append", default=[])
    parser.add_argument("--directory", type=Path, action="append", default=[])
    parser.add_argument("--bind", nargs=2, action="append", default=[])
    parser.add_argument("--ro-bind", nargs=2, action="append", default=[])
    parser.add_argument("--setenv", nargs=2, action="append", default=[])
    parser.add_argument("command", nargs=argparse.REMAINDER)
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()
    sandbox_command = args.command

    user_home = str(Path("/home") / args.user)
    environment = {
        EnvironmentField.HOME: user_home,
        EnvironmentField.PATH: args.runtime_path,
        EnvironmentField.USER: args.user,
        EnvironmentField.LOGNAME: args.user,
        EnvironmentField.TERM: "xterm-256color",
        EnvironmentField.LD_LIBRARY_PATH: args.library_path,
        EnvironmentField.LIBRARY_PATH: args.library_path,
        EnvironmentField.PKG_CONFIG_PATH: args.pkg_config_path,
    }
    if args.terminfo is not None:
        environment[EnvironmentField.TERMINFO] = args.terminfo
    if args.ssl_cert_file is not None:
        environment[EnvironmentField.SSL_CERT_FILE] = args.ssl_cert_file
    if args.ssl_cert_dir is not None:
        environment[EnvironmentField.SSL_CERT_DIR] = args.ssl_cert_dir
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
    roots = find_roots(Marker.GIT) or [Path.cwd()]
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
