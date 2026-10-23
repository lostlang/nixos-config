#!/usr/bin/env python3

import argparse
import argcomplete
import os
import subprocess
import sys
from pathlib import Path

from lib.cli import help_requested
from lib.filesystem import find_named_files
from lib.find_folders import Marker, find_roots
from lib.project_sessions import project_session_name


def main():
    help_mode = help_requested()

    executables_parser = argparse.ArgumentParser(add_help=False)
    zellij_option = executables_parser.add_argument("--zellij-executable")
    if not help_mode:
        zellij_option.required = True

    dependency_parser = argparse.ArgumentParser(
        add_help=False, parents=[executables_parser]
    )
    config_dir_option = dependency_parser.add_argument("--config-dir", type=Path)
    args, _ = dependency_parser.parse_known_args()
    if not help_mode:
        config_dir_option.required = True

    layouts = []
    if args.config_dir is not None:
        layouts = list(find_named_files(args.config_dir / "layouts", ".kdl"))

    parser = argparse.ArgumentParser(parents=[dependency_parser])
    parser.add_argument("--layout", required=True, choices=layouts)
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    roots = find_roots(Marker.GIT) or find_roots(Marker.NIX) or [Path.cwd()]
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
