from enum import StrEnum
from pathlib import Path

from .find_folders import Marker, find_nested, find_roots


class FlakeGroup(StrEnum):
    SYSTEM = "system"
    CURRENT = "current"


def find_flake_dirs(system_dir):
    system_dir = Path(system_dir).resolve()
    flake_dirs = {}

    system_flakes = find_nested(Marker.NIX, system_dir)
    if system_flakes:
        flake_dirs[FlakeGroup.SYSTEM] = system_flakes

    current_flakes = []
    for directory in find_roots(Marker.NIX):
        if not directory.is_relative_to(system_dir):
            current_flakes.append(directory)
    if current_flakes:
        flake_dirs[FlakeGroup.CURRENT] = current_flakes

    return flake_dirs
