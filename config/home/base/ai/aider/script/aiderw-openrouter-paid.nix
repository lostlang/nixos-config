{
  aiderw,
  lib,
  pkgs,
  provider,
  secret,
  ...
}:
let
  models = builtins.concatStringsSep "\n" (
    map (model: model.name) provider.openrouterPaid.model.chat
  );
  weakModel = provider.openrouterPaid.model.weak;
  weakArg = lib.optionalString (weakModel != "") "--weak-model \"openai/${weakModel}\"";
in
pkgs.writeShellScriptBin "aiderw-openrouter-paid" ''
  #!/usr/bin/env bash
  set -euo pipefail

  models="${models}"

  selected_model=$(printf "%s\n" "$models" | ${pkgs.fzf}/bin/fzf --prompt="Select an OpenRouter PAID model: ")

  exec ${aiderw}/bin/aiderw \
    --openai-api-base "${provider.openrouterPaid.api_base}" \
    --openai-api-key "${secret.apiKey.llm.paid.openrouter}" \
    --model "openai/$selected_model" \
    ${weakArg} \
    "$@"
''
