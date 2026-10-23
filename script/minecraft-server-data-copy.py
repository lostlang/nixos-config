#!/usr/bin/env python3

import argparse
import argcomplete
import shutil
import sys
from enum import StrEnum
from pathlib import Path


class ServerFile(StrEnum):
    WORLD = "world"
    EULA = "eula.txt"
    OPS = "ops.json"
    PROPERTIES = "server.properties"
    USER_CACHE = "usercache.json"
    USERNAME_CACHE = "usernamecache.json"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("source_dir", type=Path)
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    if not args.source_dir.is_dir():
        parser.error(
            f"source directory not found or not a directory: {args.source_dir}"
        )

    for name in ServerFile:
        source = args.source_dir / name
        if not source.exists():
            print(f"Skipped (not found): {name}")
            continue
        destination = Path.cwd() / name
        if source.is_dir() and not source.is_symlink():
            shutil.copytree(source, destination, symlinks=True, dirs_exist_ok=True)
        else:
            shutil.copy2(source, destination, follow_symlinks=False)
        print(f"Copied: {name}")

    print("Copy complete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
