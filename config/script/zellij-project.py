#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys

from lib.project_context import find_project_root, project_session_name


def active_sessions(zellij_executable):
    result = subprocess.run(
        [zellij_executable, "list-sessions", "--no-formatting"],
        capture_output=True,
        text=True,
    )
    sessions = set()
    for line in result.stdout.splitlines():
        if not line.strip() or "EXITED" in line:
            continue
        sessions.add(line.split()[0])

    return sessions


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--zellij-executable", required=True)
    parser.add_argument("--git-executable", required=True)
    parser.add_argument("--layout", required=True)
    args = parser.parse_args()

    project_dir = str(find_project_root(executable=args.git_executable))
    session = project_session_name(args.layout, project_dir)

    if os.environ.get("ZELLIJ"):
        if os.environ.get("ZELLIJ_SESSION_NAME") == session:
            return 0
        if session not in active_sessions(args.zellij_executable):
            subprocess.run(
                [
                    args.zellij_executable,
                    "attach",
                    "--create-background",
                    "--force-run-commands",
                    session,
                    "options",
                    "--default-cwd",
                    project_dir,
                    "--default-layout",
                    args.layout,
                ],
                check=True,
            )
        command = [
            "action",
            "switch-session",
            session,
        ]
    else:
        command = [
            "attach",
            "--create",
            "--force-run-commands",
            session,
            "options",
            "--default-cwd",
            project_dir,
            "--default-layout",
            args.layout,
        ]
    result = subprocess.run(
        [args.zellij_executable, *command],
        check=True,
    )

    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
