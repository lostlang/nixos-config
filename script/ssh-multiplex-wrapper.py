#!/usr/bin/env python3

import argparse
import os
import shlex
import sys

OPTIONS_WITH_ARGUMENTS = {
    "-B",
    "-b",
    "-c",
    "-D",
    "-E",
    "-e",
    "-F",
    "-i",
    "-J",
    "-l",
    "-m",
    "-O",
    "-o",
    "-P",
    "-p",
    "-S",
    "-W",
    "-w",
}

OPTIONS_WITH_PORT_FORWARDING = {"-L", "-R"}


def server_without_command(args):
    index = 0

    while index < len(args):
        argument = args[index]
        if argument == "--":
            index += 1
            break

        if not argument.startswith("-") or argument == "-":
            break

        option = argument[:2]
        if option in OPTIONS_WITH_PORT_FORWARDING:
            return None

        if option in OPTIONS_WITH_ARGUMENTS and len(argument) == 2:
            index += 1
        index += 1

    if index < len(args) and index == len(args) - 1:
        return args[index]

    return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ssh-executable", required=True)
    parser.add_argument("--session-name", required=True)
    parser.add_argument("--ssh-args", nargs=argparse.REMAINDER, default=[])
    parsed_args, remaining_args = parser.parse_known_args()

    args = parsed_args.ssh_args + remaining_args

    server = server_without_command(args)
    session_name = shlex.quote(parsed_args.session_name)

    if server is not None:
        remote_commands = []
        if not os.environ.get("ZELLIJ"):
            remote_commands.append(
                "if command -v zellij >/dev/null 2>&1; then "
                f"zellij attach --create {session_name} && exit 0; "
                "fi;"
            )
        if not os.environ.get("TMUX"):
            remote_commands.append(
                "if command -v tmux >/dev/null 2>&1; then "
                f"tmux new-session -A -s {session_name} && exit 0; "
                "fi;"
            )
        remote_commands.append('exec "${SHELL:-/bin/sh}" -l')
        remote_command = " ".join(remote_commands)

        os.execv(
            parsed_args.ssh_executable,
            [parsed_args.ssh_executable, "-t", *args, remote_command],
        )

    os.execv(parsed_args.ssh_executable, [parsed_args.ssh_executable, *args])


if __name__ == "__main__":
    sys.exit(main())
