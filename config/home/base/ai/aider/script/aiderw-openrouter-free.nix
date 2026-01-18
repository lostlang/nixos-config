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
    map (model: model.name) provider.openrouterFree.model.chat
  );
  weakModel = provider.openrouterFree.model.weak;
  weakArg = lib.optionalString (weakModel != "") "--weak-model \"openai/${weakModel}\"";
in
pkgs.writeShellScriptBin "aiderw-openrouter-free" ''
  #!/usr/bin/env bash
  set -euo pipefail

  models="${models}"

  selected_model=$(printf "%s\n" "$models" | ${pkgs.fzf}/bin/fzf --prompt="Select an OpenRouter FREE model: ")

  exec ${aiderw}/bin/aiderw \
    --openai-api-base "${provider.openrouterFree.api_base}" \
    --openai-api-key "${secret.apiKey.llm.free.openrouter}" \
    --model "openai/$selected_model" \
    ${weakArg} \
    "$@"
''
