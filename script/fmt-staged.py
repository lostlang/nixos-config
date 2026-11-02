#!/usr/bin/env python3

import argparse
import argcomplete
import os
import subprocess
import sys
from pathlib import Path

from lib.find_folders import Marker, find_roots


def main():
    executables_parser = argparse.ArgumentParser(add_help=False)
    executables_parser.add_argument("--git-executable", required=True)
    executables_parser.add_argument("--nix-executable", required=True)

    parser = argparse.ArgumentParser(parents=[executables_parser])
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    roots = find_roots(Marker.GIT) or [Path.cwd()]
    project_root = roots[0]

    try:
        staged_paths = subprocess.run(
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
        print("run this command from inside a Git repository", file=sys.stderr)
        return 1

    staged_files = []
    for path in staged_paths:
        if path:
            staged_files.append(os.fsdecode(path))

    if not staged_files:
        return 0

    return subprocess.run(
        [args.nix_executable, "fmt", *staged_files], cwd=project_root, check=False
    ).returncode


if __name__ == "__main__":
    sys.exit(main())
