#!/usr/bin/env python3

import argparse
import argcomplete
import os
import subprocess
import sys

from lib.fzf import select
from lib.project_sessions import is_project_session


def main():
    executables_parser = argparse.ArgumentParser()
    required_executables = [
        executables_parser.add_argument("--fzf-executable"),
        executables_parser.add_argument("--zellij-executable"),
    ]
    args, _ = executables_parser.parse_known_args()
    for option in required_executables:
        option.required = True

    sessions = {}
    discovery_returncode = 0
    if args.zellij_executable is not None:
        result = subprocess.run(
            [args.zellij_executable, "list-sessions", "--no-formatting"],
            capture_output=True,
            text=True,
        )
        discovery_returncode = result.returncode
        for line in result.stdout.splitlines():
            if not line.strip():
                continue
            label = line.split()[0]
            if not is_project_session(label):
                continue
            sessions[label] = line

    parser = argparse.ArgumentParser(add_help=False, parents=[executables_parser])
    parser.add_argument("target", nargs="?", choices=list(sessions))
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    if not sessions:
        print("no zp sessions found.")
        return discovery_returncode

    selected = args.target
    if selected is None:
        selected = select(sessions, prompt="Session: ", executable=args.fzf_executable)
        if selected is None:
            return 0

    line = sessions[selected]
    session = line.split()[0]
    if os.environ.get("ZELLIJ"):
        if os.environ.get("ZELLIJ_SESSION_NAME") == session:
            return 0
        command = ["action", "switch-session", session]
    else:
        command = ["attach", session]

    result = subprocess.run([args.zellij_executable, *command], check=True)

    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
