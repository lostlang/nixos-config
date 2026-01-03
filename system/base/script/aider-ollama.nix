{ pkgs, ... }:
pkgs.writeShellScriptBin "aiderw-ollama" ''
  #!/usr/bin/env bash
  set -euo pipefail

  models="qwen3:0.6b
  qwen3:1.7b
  qwen2.5-coder:0.5b
  qwen2.5-coder:1.5b
  "

  selected_model=$(printf "%s\n" "$models" | ${pkgs.fzf}/bin/fzf --prompt="Select an Ollama model: ")

  exec aiderw \
    --openai-api-base "http://127.0.0.1:11434/v1" \
    --model "ollama/$selected_model" \
    --weak-model "ollama/qwen3:0.6b" \
    "$@"
''
