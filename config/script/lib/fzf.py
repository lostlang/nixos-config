"""Reusable helpers for interactive fzf selection."""

import subprocess


def select(items, prompt="Select an item: ", executable="fzf"):
    """Return the selected item, or None when the selection is cancelled."""
    result = subprocess.run(
        [
            executable,
            "--height=~50%",
            "--reverse",
            f"--prompt={prompt}",
        ],
        input="\n".join(items) + "\n",
        text=True,
        capture_output=True,
    )

    if result.returncode != 0:
        return None

    return result.stdout.rstrip("\n") or None
