{ pkgs, ... }:
pkgs.writeShellScriptBin "init-env" ''
  #!/usr/bin/env bash
  set -euo pipefail

  if [ $# -eq 0 ]; then
    if [ -f ".envrc" ]; then
      echo "The .envrc file already exists"
    else
      echo 'use flake . --impure' > .envrc
      direnv allow
    fi
  fi

  case "$1" in
    go)
      if [ -f "./flake.nix" ]; then
        echo "The flake.nix file already exists"
      else
        cp -v $HOME/.config/nixos/env/go.flake.nix ./flake.nix
        "$0"
      fi
      ;;
    minecraft)
      if [ -f "./flake.nix" ]; then
        echo "The flake.nix file already exists"
      else
        cp -v $HOME/.config/nixos/env/minecraft.flake.nix ./flake.nix
        "$0"
      fi
      ;;
    *)
      echo "Valid param: {go|minecraft}"
      exit 1
      ;;
  esac
''
