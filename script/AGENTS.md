# Python and Nix script style guide

- Keep application logic in Python.
- Manage Python dependencies in `script/pyproject.toml`.
- Manage all other dependencies and package installation in Nix.

## Python structure

- Use a flat `example.py` file for a standalone script.
- Put shared, reused Python functions in `./lib`.
- Avoid creating helpers used once merely to split a short script into more functions. Do not add a separate `parse_args()` or `build_command()` solely for a small script's structure.
- Name arguments that receive executable paths `--tool-executable`, for example `--git-executable`.
- For interactive selection scripts, accept an optional positional argument (`nargs="?"`) with `choices` so users can select directly; open fzf only when the argument is omitted.
- For fixed named choices and structured-data field names used throughout a script, use `StrEnum` and reference its members instead of repeating strings.
- Separate executable arguments into `executables_parser` and inherit them in the final parser. Add a dependency parser only when arguments must be read before dynamic choices can be built. Use `add_help=False` on parent parsers and inherit each argument only once.
- When parsing more than once, use `lib.cli.help_requested()` to avoid enforcing preliminary required arguments in help mode: set argument objects to `required = True` only when `not help_mode`. The final parser handles help.
- Before using a preliminary value, check whether it was supplied. Initialize choices to an empty list when dependencies are absent. Required arguments added only to the final parser can use `required=True` directly.
- Use early returns to reduce nesting where they make the normal path clearer.
- Do not write comments. Make the code easy to understand through descriptive names, explicit steps, and simple control flow. Rewrite unclear code instead of adding a comment to explain it.

```python
#!/usr/bin/env python3

import argparse
import argcomplete
import json
import subprocess
import sys
from enum import StrEnum
from pathlib import Path

from lib.cli import help_requested
from lib.fzf import select


class NodeField(StrEnum):
    ENABLED = "enabled"
    NAME = "name"


def main():
    help_mode = help_requested()

    executables_parser = argparse.ArgumentParser(add_help=False)
    required_executables = [
        executables_parser.add_argument("--fzf-executable"),
        executables_parser.add_argument("--tool-executable"),
    ]
    if not help_mode:
        for option in required_executables:
            option.required = True

    dependency_parser = argparse.ArgumentParser(add_help=False, parents=[executables_parser])
    required_dependencies = [
        dependency_parser.add_argument("--input-file", type=Path),
    ]
    args, _ = dependency_parser.parse_known_args()
    if not help_mode:
        for option in required_dependencies:
            option.required = True

    active_names = []
    if args.input_file is not None:
        nodes = json.loads(args.input_file.read_text())
        for node in nodes:
            if not node[NodeField.ENABLED]:
                continue
            name = node[NodeField.NAME].strip()
            active_names.append(name)

    parser = argparse.ArgumentParser(
        parents=[dependency_parser]
    )
    parser.add_argument("--config-dir", required=True)
    parser.add_argument("target", nargs="?", choices=["all", *active_names])
    argcomplete.autocomplete(parser, always_complete_options=False)
    args = parser.parse_args()

    target = args.target
    if target is None:
        target = select(
            ["all", *active_names], prompt="Target: ", executable=args.fzf_executable
        )
        if target is None:
            return 0

    selected_names = active_names if target == "all" else [target]
    return subprocess.run(
        [args.tool_executable, "--config", args.config_dir, *selected_names], check=True
    ).returncode


if __name__ == "__main__":
    sys.exit(main())
```

## Nix structure

- Pass configuration from Nix through named command-line arguments.
- Use repeatable options for lists, mounts, and environment assignments. Build these as an argument list with `lib.concatMap`, then quote the complete list with `lib.escapeShellArgs`.
- Declare external tools in `runtimeInputs` and invoke them by name when the wrapper provides PATH. When an explicit executable argument is needed, resolve it in Nix with `lib.getExe` or `lib.getExe'`.
- Set list command dependencies in `runtimeInputs`.
- Pass required Python options explicitly: resolve `--tool-executable` with `lib.getExe` or `lib.getExe'`, and quote the path passed to `--input-file` with `lib.escapeShellArg`.
- Return a module installing the command in `environment.systemPackages`. For a Home Manager module, use `home.packages` instead.
- Register commands after its completion system is initialized `config/module/core/home/zsh/completions.nix`.

```nix
{
  lib,
  pkgs,
  pythonScriptEnv,
  inputFile,
  ...
}:
let
  example = pkgs.writeShellApplication {
    name = "example";

    runtimeInputs = with pkgs; [
      toolPackage
      fzf
      python3
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/example.py \
        --fzf-executable ${lib.getExe pkgs.fzf} \
        --tool-executable ${lib.getExe toolPackage} \
        --input-file ${lib.escapeShellArg (toString inputFile)} \
        --config-dir "conf" \
        "$@"
    '';
  };
in
{
  environment.systemPackages = [ example ];
}
```
