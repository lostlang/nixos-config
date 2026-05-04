{
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "fmt-staged" ''
  #!/usr/bin/env bash
  set -euo pipefail

  mapfile -d $'\0' -t staged_files < <(git diff --cached --name-only --diff-filter=d -z)

  if [ "''${#staged_files[@]}" -eq 0 ]; then
    exit 0
  fi

  nix fmt "''${staged_files[@]}"
''
