{
  aiderw,
  lib,
  pkgs,
  provider,
  secret,
  ...
}:
let
  models = builtins.concatStringsSep "\n" (map (model: model.name) provider.openai.model.chat);
  weakModel = provider.openai.model.weak;
  weakArg = lib.optionalString (weakModel != "") "--weak-model \"${weakModel}\"";
in
pkgs.writeShellScriptBin "aiderw-openai" ''
  #!/usr/bin/env bash
  set -euo pipefail

  models="${models}"

  selected_model=$(printf "%s\n" "$models" | ${pkgs.fzf}/bin/fzf --prompt="Select an OpenAI model: ")

  exec ${aiderw}/bin/aiderw \
    --openai-api-base "${provider.openai.api_base}" \
    --openai-api-key "${secret.apiKey.llm.paid.openai}" \
    --model "$selected_model" \
    ${weakArg} \
    "$@"
''
