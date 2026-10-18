# Python and Nix script style guide

- Keep dependencies and package installation in Nix.
- Keep application logic in Python.

## Python structure

- Use a flat `example.py` file for a standalone script.
- Put shared, reused Python functions in `./lib`.
- Avoid creating helpers used once merely to split a short script into more functions. Do not add a separate `parse_args()` or `build_command()` solely for a small script's structure.
- Name arguments that receive executable paths `--tool-executable`, for example `--git-executable`.
- Use early returns to reduce nesting where they make the normal path clearer.
- Do not write comments. Make the code easy to understand through descriptive names, explicit steps, and simple control flow. Rewrite unclear code instead of adding a comment to explain it.

```python
#!/usr/bin/env python3

import argparse
import json
import subprocess
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--tool-executable", required=True)
    parser.add_argument("--input-file", required=True, type=Path)
    args = parser.parse_args()

    nodes = json.loads(args.input_file.read_text())
    active_names = []
    for node in nodes:
        if not node["enabled"]:
            continue
        name = node["name"].strip()
        active_names.append(name)

    subprocess.run(
        [args.tool_executable, *active_names],
        check=True,
    )


if __name__ == "__main__":
    sys.exit(main())
```

## Nix structure

- Pass configuration from Nix through named command-line arguments.
- Use repeatable options for lists, mounts, and environment assignments.
- Declare external tools in `runtimeInputs` and invoke them by name when the wrapper provides PATH. When an explicit executable argument is needed, resolve it in Nix with `lib.getExe` or `lib.getExe'`.
- Set list command dependencies in `runtimeInputs`.
- Pass required Python options explicitly: resolve `--tool-executable` with `lib.getExe` or `lib.getExe'`, and quote the path passed to `--input-file` with `lib.escapeShellArg`.
- If Python imports shared `script/lib` modules, prepend `script` to `PYTHONPATH`, preserving an existing value.
- Return a module installing the command in `environment.systemPackages`. For a Home Manager module, use `home.packages` instead.

```nix
{
  lib,
  pkgs,
  inputFile,
  ...
}:
let
  example = pkgs.writeShellApplication {
    name = "example";

    runtimeInputs = with pkgs; [
      toolPackage
      python3
    ];

    text = /* sh */ ''
      export PYTHONPATH=${./script}''${PYTHONPATH:+:$PYTHONPATH}

      exec ${lib.getExe pkgs.python3} ${./example.py} \
        --tool-executable ${lib.getExe toolPackage} \
        --input-file ${lib.escapeShellArg (toString inputFile)} \
        "$@"
    '';
  };
in
{
  environment.systemPackages = [ example ];
}
```
