#!/usr/bin/env python3

import os
import subprocess
import sys

from lib.project_context import find_project_root


def main():
    project_root = find_project_root()

    try:
        staged_files = subprocess.run(
            ["git", "diff", "--cached", "--name-only", "--diff-filter=d", "-z"],
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
        ["nix", "fmt", *staged_files], cwd=project_root, check=False
    ).returncode


if __name__ == "__main__":
    sys.exit(main())
