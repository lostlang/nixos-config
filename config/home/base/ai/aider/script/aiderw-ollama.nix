{
  aiderw,
  lib,
  pkgs,
  provider,
  ...
}:
let
  models = builtins.concatStringsSep "\n" (map (model: model.name) provider.ollamaLocal.model.chat);
  weakModel = provider.ollamaLocal.model.weak;
  weakArg = lib.optionalString (weakModel != "") "--weak-model \"ollama/${weakModel}\"";
in
pkgs.writeShellScriptBin "aiderw-ollama" ''
  #!/usr/bin/env bash
  set -euo pipefail

  models="${models}"

  selected_model=$(printf "%s\n" "$models" | ${pkgs.fzf}/bin/fzf --prompt="Select an Ollama model: ")

  exec ${aiderw}/bin/aiderw \
    --openai-api-base "${provider.ollamaLocal.api_base}" \
    --model "ollama/$selected_model" \
    ${weakArg} \
    "$@"
''
