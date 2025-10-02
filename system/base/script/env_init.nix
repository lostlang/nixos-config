{ pkgs, ... }:
pkgs.writeShellScriptBin "env-init" ''
  #!/usr/bin/env bash
  set -euo pipefail

  arg="''${1:-}"

  case "$arg" in
    go)
      if [ -f "flake.nix" ]; then
        echo "The flake.nix file already exists"
      else
        cp -v $HOME/.config/nixos/env/go.flake.nix ./flake.nix
      fi
      ;;
    minecraft)
      if [ -f "./flake.nix" ]; then
        echo "The flake.nix file already exists"
      else
        cp -v $HOME/.config/nixos/env/minecraft.flake.nix ./flake.nix
      fi
      ;;
    *)
      echo "Valid param: {go|minecraft}"
      ;;
  esac

  if [ -d ".git" ]; then
    git add flake.nix
  fi

  if [ -f ".envrc" ]; then
    echo "The .envrc file already exists"
  else
    echo 'use flake . --impure' > .envrc
    direnv allow
  fi
''
