{ pkgs, secret, ... }:
pkgs.writeShellScriptBin "aiderw-zai" ''
  #!/usr/bin/env bash
  set -euo pipefail

  models="glm-4.7
  glm-4.6
  glm-4.5
  glm-4.5-air
  glm-4.5-x
  glm-4.5-airx
  glm-4.5-flash
  glm-4-32b-0414-128k
  "
  selected_model=$(printf "%s\n" "$models" | ${pkgs.fzf}/bin/fzf --prompt="Select a ZAI model: ")

  exec aiderw \
    --openai-api-base "https://api.z.ai/api/coding/paas/v4" \
    --openai-api-key "${secret.zai.apiKeys.paid}" \
    --model "openai/$selected_model" \
    --weak-model "openai/glm-4.5-flash" \
    "$@"
''
