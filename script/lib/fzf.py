import subprocess


def select(items, prompt, executable):
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
