{
  aiderw,
  lib,
  pkgs,
  provider,
  secret,
  ...
}:
let
  models = builtins.concatStringsSep "\n" (map (model: model.name) provider.zai.model.chat);
  weakModel = provider.zai.model.weak;
  weakArg = lib.optionalString (weakModel != "") ''--weak-model "openai/${weakModel}"'';
in
pkgs.writeShellScriptBin "aiderw-zai" ''
  #!/usr/bin/env bash
  set -euo pipefail

  models="${models}"

  selected_model=$(printf "%s\n" "$models" | ${pkgs.fzf}/bin/fzf --prompt="Select a ZAI model: ")

  exec ${aiderw}/bin/aiderw \
    --openai-api-base "${provider.zai.api_base}" \
    --openai-api-key "${secret.apiKey.llm.paid.zai}" \
    --model "openai/$selected_model" \
    ${weakArg} \
    "$@"
''
