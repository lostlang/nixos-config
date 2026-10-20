#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
from pathlib import Path


def main():
    executables_parser = argparse.ArgumentParser(add_help=False)
    executables_parser.add_argument("--bw-executable", required=True)

    parser = argparse.ArgumentParser(parents=[executables_parser])
    parser.add_argument("--session-file", type=Path, required=True)
    parser.add_argument("--command", nargs=argparse.REMAINDER, default=[])
    args, remaining_args = parser.parse_known_args()

    command = args.command + remaining_args

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
