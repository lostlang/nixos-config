{ pkgs, ... }:
pkgs.writeShellScriptBin "clean" ''
  #!/usr/bin/env bash

  case "$1" in
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
    *)
      echo "Valid param: {all|os|home|zellij|nvim}"
      exit 1
      ;;
  esac
''
