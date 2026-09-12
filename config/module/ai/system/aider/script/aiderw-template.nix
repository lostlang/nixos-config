{
  aiderw,
  config,
  lib,
  pkgs,
  ...
}:
{
  name,
  ...
}:
let
  secret = lib.attrByPath [ "sops" "secrets" "ai.provider.${name}.apiKey" ] null config;
  apiKeyPath = if secret != null then secret.path else null;

  provider = config.myConfig.ai.provider.${name};
  modelPrefix = if provider.model.prefix != "" then "${provider.model.prefix}/" else "";

  models = builtins.concatStringsSep "\n" (map (model: model.name) provider.model.chat);
  weakModel = provider.model.weak;
  weakArg = lib.optionalString (weakModel != "") ''--weak-model "${modelPrefix}${weakModel}"'';

  apiKeyBlock = lib.optionalString (apiKeyPath != null) ''
    api_key="$(cat ${apiKeyPath})"
    if [ -z "$api_key" ]; then
      echo "Error: ${name} API key is empty." >&2
      exit 1
    fi
  '';

  apiKeyArg = lib.optionalString (apiKeyPath != null) ''
    --openai-api-key "$api_key" \
  '';
in
pkgs.writeShellScriptBin "aiderw-${name}" ''
  #!/usr/bin/env bash
  set -euo pipefail

  models="${models}"

  selected_model=$(printf "%s\n" "$models" | ${pkgs.fzf}/bin/fzf --prompt="Select an ${name} model:")

  ${apiKeyBlock}

  exec ${aiderw}/bin/aiderw \
    --openai-api-base "${provider.apiBase}" \
    ${apiKeyArg} \
    --model "${modelPrefix}$selected_model" \
    ${weakArg} \
    "$@"
''
