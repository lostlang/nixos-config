#!/usr/bin/env python3

import argparse
import argcomplete
import secrets
import subprocess
import sys
from pathlib import Path


def main():
    executables_parser = argparse.ArgumentParser(add_help=False)
    executables_parser.add_argument("--librewolf-executable", required=True)

    parser = argparse.ArgumentParser(parents=[executables_parser])
    parser.add_argument("--render-html", type=Path, required=True)
    parser.add_argument("--count", type=int, default=1)
    parser.add_argument("--resolution", action="append", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--render-scale", type=float, default=1)
    parser.add_argument("--seed", type=int)
    parser.add_argument("--no-logo", action="store_true")
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    resolutions = []
    for resolution in dict.fromkeys(args.resolution):
        dimensions = resolution.split("x")
        width, height = map(int, dimensions)
        resolutions.append((width, height))

    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)

    first_seed = args.seed
    if first_seed is None:
        first_seed = secrets.randbits(32)

    url = args.render_html.resolve().as_uri()
    for width, height in resolutions:
        render_width = round(width * args.render_scale)
        render_height = round(height * args.render_scale)
        resolution_output = output / f"wallpaper_{width}x{height}"
        resolution_output.mkdir(parents=True, exist_ok=True)

        for index in range(args.count):
            seed = first_seed + index
            path = resolution_output / f"wallpaper-{seed}.png"

            subprocess.run(
                [
                    args.librewolf_executable,
                    "--headless",
                    "--new-instance",
                    "--window-size",
                    f"{render_width},{render_height}",
                    "--screenshot",
                    str(path),
                    f"{url}?seed={seed}&export=1" + ("&logo=0" if args.no_logo else ""),
                ],
                check=True,
                text=True,
                timeout=60,
            )

    return 0


if __name__ == "__main__":
    sys.exit(main())
