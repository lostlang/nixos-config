{
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "clean" ''
  #!/usr/bin/env bash
  set -euo pipefail

  params="all
  home
  nvim
  os
  zellij"

  selected_param=$(printf "%s\n" "$params" | ${pkgs.fzf}/bin/fzf --prompt="Select what to clean: ")

  case "$selected_param" in
    os)
      sudo nix-collect-garbage -d
      ;;
    home)
      nix-collect-garbage -d
      ;;
    zellij)
      zellij delete-all-sessions -y
      ;;
    nvim)
      rm $HOME/.local/state/nvim/swap/*
      ;;
    all)
      sudo nix-collect-garbage -d
      nix-collect-garbage -d
      zellij delete-all-sessions -y
      rm $HOME/.local/state/nvim/swap/*
      ;;
  esac
''
