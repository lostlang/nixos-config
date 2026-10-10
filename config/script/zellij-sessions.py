#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys

from lib.fzf import select
from lib.project_context import is_project_session


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--fzf-executable", required=True)
    parser.add_argument("--zellij-executable", required=True)
    args = parser.parse_args()

    result = subprocess.run(
        [args.zellij_executable, "list-sessions", "--no-formatting"],
        capture_output=True,
        text=True,
    )
    sessions = {}
    for line in result.stdout.splitlines():
        if line.strip():
            label = line.split()[0]
            if not is_project_session(label):
                continue
            sessions[label] = line
    if not sessions:
        print("No zp sessions found.")
        return result.returncode

    selected = select(sessions, prompt="Session: ", executable=args.fzf_executable)
    if selected is None:
        return 0

    line = sessions[selected]
    session = line.split()[0]
    if os.environ.get("ZELLIJ"):
        if os.environ.get("ZELLIJ_SESSION_NAME") == session:
            return 0
        if "EXITED" in line:
            subprocess.run(
                [
                    args.zellij_executable,
                    "attach",
                    "--create-background",
                    "--force-run-commands",
                    session,
                ],
                check=True,
            )
        command = ["action", "switch-session", session]
    else:
        command = ["attach", "--force-run-commands", session]

    result = subprocess.run([args.zellij_executable, *command], check=True)

    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
