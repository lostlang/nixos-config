{ pkgs, secret, ... }:
let
  hasOpenrouterPaid = secret.openrouter.apiKeys.paid != "";
  defaultKey =
    if hasOpenrouterPaid then secret.openrouter.apiKeys.paid else secret.openrouter.apiKeys.free;
in
pkgs.writeShellScriptBin "aiderw-openrouter" ''
  #!/usr/bin/env bash
  set -euo pipefail

  models="xiaomi/mimo-v2-flash:free"

  selected_model=$(printf "%s\n" "$models" | sort -u | ${pkgs.fzf}/bin/fzf --prompt="Select an OpenRouter model: ")

  exec aiderw \
    --openai-api-base "https://openrouter.ai/api/v1" \
    --openai-api-key "${defaultKey}" \
    --model "openai/$selected_model" \
    "$@"
''
