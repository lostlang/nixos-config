{
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "env-init" ''
  #!/usr/bin/env bash
  set -euo pipefail

  env_dir="$HOME/.config/nixos/env"

  mapfile -t env_files < <(ls -1 "$env_dir"/*.flake.nix 2>/dev/null || true)

  env_names=$(
    for file in "''${env_files[@]}"; do
      basename "$file" .flake.nix
    done
  )

  selected_param=$(printf "%s\n" "$env_names" | ${pkgs.fzf}/bin/fzf --prompt="Select environment: ")

  if [ -z "$selected_param" ]; then
    exit 0
  fi

  if [ -f "./flake.nix" ]; then
    echo "The flake.nix file already exists"
  else
    cp -v "$env_dir/$selected_param.flake.nix" ./flake.nix
  fi

  if [ -d ".git" ]; then
    git add flake.nix
  fi
''
