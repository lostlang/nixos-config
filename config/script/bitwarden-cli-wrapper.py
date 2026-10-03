#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bw-executable", required=True)
    parser.add_argument("--session-file", required=True, type=Path)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()

    command = args.command
    if command and command[0] == "--":
        command = command[1:]

    env = os.environ.copy()
    if args.session_file.is_file():
        env["BW_SESSION"] = args.session_file.read_text().strip()

    result = subprocess.run(
        [args.bw_executable, *command],
        check=True,
        env=env,
    )

    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
