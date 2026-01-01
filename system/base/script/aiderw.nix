{ pkgs, ... }:
pkgs.writeShellScriptBin "aiderw" ''
  exec ${pkgs.aider-chat}/bin/aider \
    --watch-files \
    --user-input-color "#437F06" \
    --tool-output-color "#10072B" \
    --tool-error-color "#AE2626" \
    --tool-warning-color "#9B8318" \
    --assistant-output-color "#23569F" \
    --completion-menu-bg-color "#EDDFBF" \
    --completion-menu-color "#10072B" \
    --completion-menu-current-bg-color "#437F06" \
    --completion-menu-current-color "#10072B" \
    --code-theme "autumn" \
    --no-gitignore \
    --notifications \
    --no-show-model-warnings \
    --no-auto-commits \
    --no-dirty-commits \
    --edit-format diff \
    "$@"
''
