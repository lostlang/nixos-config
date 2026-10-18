#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
from pathlib import Path

from lib.find_folders import find_roots


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--git-executable", required=True)
    parser.add_argument("--nix-executable", required=True)
    args = parser.parse_args()

    roots = find_roots("git") or [Path.cwd()]
    project_root = roots[0]

    try:
        staged_files = subprocess.run(
            [
                args.git_executable,
                "diff",
                "--cached",
                "--name-only",
                "--diff-filter=d",
                "-z",
            ],
            cwd=project_root,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ).stdout.split(b"\0")
    except subprocess.CalledProcessError:
        print(
            "fmt-staged: run this command from inside a Git repository", file=sys.stderr
        )
        return 1

    staged_files = [os.fsdecode(path) for path in staged_files if path]

    if not staged_files:
        return 0

    return subprocess.run(
        [args.nix_executable, "fmt", *staged_files], cwd=project_root, check=False
    ).returncode


if __name__ == "__main__":
    sys.exit(main())
