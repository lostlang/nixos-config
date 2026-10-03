#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bw-executable", required=True)
    parser.add_argument("--password-file", required=True, type=Path)
    parser.add_argument("--session-file", required=True, type=Path)
    args = parser.parse_args()

    unlock = subprocess.run(
        [
            args.bw_executable,
            "unlock",
            "--passwordfile",
            str(args.password_file),
            "--raw",
        ],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    )

    args.session_file.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    session_fd = os.open(
        args.session_file,
        os.O_WRONLY | os.O_CREAT | os.O_TRUNC,
        0o600,
    )
    with os.fdopen(session_fd, "w") as session_file:
        session_file.write(unlock.stdout.strip())


if __name__ == "__main__":
    sys.exit(main())
