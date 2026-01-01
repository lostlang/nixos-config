{ pkgs, ... }:
pkgs.writeShellScriptBin "aiderw" ''
  exec ${pkgs.aider-chat}/bin/aider \
    --watch-files \
    --no-gitignore \
    --notifications \
    --no-show-model-warnings \
    --no-auto-commits \
    --no-dirty-commits \
    --chat-language "ru" \
    --edit-format "diff" \
    "$@"
''
