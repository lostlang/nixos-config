{ pkgs, secret, ... }:
let
  hasOpenrouterPaid = secret.openrouter.apiKeys.paid != "";
  defaultKey =
    if hasOpenrouterPaid then secret.openrouter.apiKeys.paid else secret.openrouter.apiKeys.free;
in
pkgs.writeShellScriptBin "aiderw-openrouter" ''
  #!/usr/bin/env bash
  set -euo pipefail

  models="xiaomi/mimo-v2-flash:free
  mistralai/devstral-2512:free
  qwen/qwen3-coder:free
  ${
    if hasOpenrouterPaid then
      ''
        qwen/qwen-turbo
      ''
    else
      ""
  }"

  selected_model=$(printf "%s\n" "$models" | ${pkgs.fzf}/bin/fzf --prompt="Select an OpenRouter model: ")

  exec aiderw \
    --openai-api-base "https://openrouter.ai/api/v1" \
    --openai-api-key "${defaultKey}" \
    --model "openai/$selected_model" \
    "$@"
''
