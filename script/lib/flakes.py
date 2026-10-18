from pathlib import Path

from .find_folders import find_nested, find_roots


def find_flake_dirs(system_dir):
    system_dir = Path(system_dir).resolve()
    flake_dirs = {}

    system_flakes = find_nested("nix", system_dir)
    if system_flakes:
        flake_dirs["system"] = system_flakes

    current_flakes = []
    for directory in find_roots("nix"):
        if not directory.is_relative_to(system_dir):
            current_flakes.append(directory)
    if current_flakes:
        flake_dirs["current"] = current_flakes

    return flake_dirs
