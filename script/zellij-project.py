#!/usr/bin/env python3

import argparse
import argcomplete
import os
import subprocess
import sys
from pathlib import Path

from lib.find_folders import find_roots
from lib.project_sessions import project_session_name


def main():
    executables_parser = argparse.ArgumentParser(add_help=False)
    required_executables = [
        executables_parser.add_argument("--zellij-executable"),
    ]
    for option in required_executables:
        option.required = True

    config_dir = Path(
        os.environ.get("ZELLIJ_CONFIG_DIR")
        or (
            Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
            / "zellij"
        )
    )
    layouts = []
    for path in (config_dir / "layouts").glob("*.kdl"):
        layouts.append(path.stem)
    layouts.sort()

    parser = argparse.ArgumentParser(parents=[executables_parser])
    parser.add_argument("--layout", required=True, choices=layouts)
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    roots = find_roots("git") or find_roots("nix") or [Path.cwd()]
    project_dir = str(roots[0])
    session = project_session_name(args.layout, project_dir)

    if os.environ.get("ZELLIJ"):
        if os.environ.get("ZELLIJ_SESSION_NAME") == session:
            return 0
        command = [
            "action",
            "switch-session",
            session,
            "--cwd",
            project_dir,
            "--layout",
            args.layout,
        ]
    else:
        command = [
            "attach",
            "--create",
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
