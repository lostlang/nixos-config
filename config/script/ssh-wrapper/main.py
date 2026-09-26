#!/usr/bin/env python3

import argparse
import os
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
    "-L",
    "-l",
    "-m",
    "-O",
    "-o",
    "-P",
    "-p",
    "-R",
    "-S",
    "-W",
    "-w",
}


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
        if option in OPTIONS_WITH_ARGUMENTS and len(argument) == 2:
            index += 1
        index += 1

    if index < len(args) and index == len(args) - 1:
        return args[index]

    return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--session-name", required=True)
    parser.add_argument("ssh_args", nargs=argparse.REMAINDER)
    parsed_args = parser.parse_args()

    args = parsed_args.ssh_args
    if args and args[0] == "--":
        args = args[1:]

    server = server_without_command(args)
    session_name = parsed_args.session_name

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

        os.execvp("ssh", ["ssh", "-t", *args, remote_command])

    os.execvp("ssh", ["ssh", *args])


if __name__ == "__main__":
    sys.exit(main())
