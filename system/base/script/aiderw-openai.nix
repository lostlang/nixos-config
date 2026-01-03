{ pkgs, secret, ... }:
pkgs.writeShellScriptBin "aiderw-openai" ''
  #!/usr/bin/env bash
  set -euo pipefail

  models="gpt-5-nano"
  selected_model=$(printf "%s\n" "$models" | ${pkgs.fzf}/bin/fzf --prompt="Select an OpenAI model: ")

  exec aiderw \
    --openai-api-base "https://api.openai.com/v1" \
    --openai-api-key "${secret.openai.apiKeys.paid}" \
    --model "$selected_model" \
    "$@"
''
