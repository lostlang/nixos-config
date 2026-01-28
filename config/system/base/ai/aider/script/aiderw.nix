{
  colorScheme,
  pkgs,
  ...
}:
let
  palette = colorScheme.default.palette;
in
pkgs.writeShellScriptBin "aiderw" ''
  exec ${pkgs.aider-chat-full}/bin/aider \
    --watch-files \
    --user-input-color "${palette.green}" \
    --tool-output-color "${palette.black}" \
    --tool-error-color "${palette.red}" \
    --tool-warning-color "${palette.yellow}" \
    --assistant-output-color "${palette.blue}" \
    --completion-menu-bg-color "${palette.light_white}" \
    --completion-menu-color "${palette.black}" \
    --completion-menu-current-bg-color "${palette.green}" \
    --completion-menu-current-color "${palette.black}" \
    --no-gitignore \
    --notifications \
    --no-show-model-warnings \
    --no-auto-commits \
    --no-dirty-commits \
    --edit-format diff \
    "$@"
''
