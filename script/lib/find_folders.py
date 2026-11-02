from enum import StrEnum
from pathlib import Path


class Marker(StrEnum):
    NIX = "nix"
    GIT = "git"


MARKER_PRESETS: dict[str, str] = {
    Marker.NIX: "flake.nix",
    Marker.GIT: ".git",
}


def find_roots(marker: str, directory=None):
    marker = MARKER_PRESETS.get(marker, marker)
    if directory is None:
        directory = Path.cwd()
    current_dir = Path(directory).resolve()
    directories = []
    for directory in (current_dir, *current_dir.parents):
        marker_path = directory / marker
        if marker_path.is_file() or marker_path.is_dir():
            directories.append(directory)

    return directories


def find_nested(marker: str, directory=None):
    marker = MARKER_PRESETS.get(marker, marker)
    if directory is None:
        directory = Path.cwd()
    current_dir = Path(directory).resolve()
    directories = []
    for marker_path in sorted(current_dir.rglob(marker)):
        if marker_path.is_file() or marker_path.is_dir():
            directories.append(marker_path.parent)

    return directories
