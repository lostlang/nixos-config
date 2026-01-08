{ pkgs, ... }:
pkgs.writeShellScriptBin "aiderw-zai-temp" ''
  #!/usr/bin/env bash
  set -euo pipefail

  dir="/tmp/$(${pkgs.coreutils}/bin/pwd)"

  ${pkgs.coreutils}/bin/mkdir -p $dir

  exec aiderw-zai \
    --input-history-file "$dir/.aider.input.history" \
    --chat-history-file "$dir/.aider.chat.history.md" \
    --no-git \
    "$@"
''
