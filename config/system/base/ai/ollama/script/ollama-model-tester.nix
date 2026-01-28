{
  pkgs,
  provider,
  ...
}:
let
  models = builtins.concatStringsSep "\n" (map (model: model.name) provider.model.chat);
in
pkgs.writeShellScriptBin "ollama-model-tester" ''
  #!/usr/bin/env bash

  models="${models}"

  model=$(echo "$models" | ${pkgs.fzf}/bin/fzf --prompt="Select Ollama model: ")
  prompt='Write simple python script tcp client and server, use only std libs.'

  response=$(curl -s ${provider.apiBase}/api/generate -d "{
    \"model\": \"$model\",
    \"prompt\": \"$prompt\",
    \"stream\": false
  }")

  eval_count=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.eval_count')
  eval_duration=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.eval_duration')

  if [ "$eval_count" = "null" ] || [ "$eval_duration" = "null" ]; then
    echo "Error: Ollama response is invalid or empty"
    exit 1
  fi

  tps=$(echo "scale=2; $eval_count / ($eval_duration / 1000000000)" | ${pkgs.bc}/bin/bc)

  echo "Model: $model"
  echo "Prompt: \"$prompt\""
  echo "Generated tokens: $eval_count"
  echo "Generation time: $eval_duration nanoseconds"
  echo "Speed: $tps tokens per second"
''
