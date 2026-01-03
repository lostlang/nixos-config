{ pkgs, ... }:
pkgs.writeShellScriptBin "env-init" ''
  #!/usr/bin/env bash
  set -euo pipefail

  params="go
  minecraft
  "

  selected_param=$(printf "%s\n" "$params" | ${pkgs.fzf}/bin/fzf --prompt="Select environment: ")

  case "$selected_param" in
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
