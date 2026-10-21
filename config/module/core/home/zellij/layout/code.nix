{
  colorScheme,
  config,
  lib,
  zjstatus,
  ...
}:
let
  statusBar = import ../status-bar.nix {
    inherit colorScheme zjstatus;
  };
in
''
  layout {
    tab name="editor" {
      pane {
        command "nvim"
        args "."
      }
    }
    ${lib.optionalString config.programs.codex.enable ''
      tab name="agent" {
        pane {
          command "codex"
        }
      }
    ''}
    tab name="lazygit" {
      pane {
        command "lazygit"
      }
    }
    tab name="terminal" {
      pane
    }

    default_tab_template {
      children

      ${statusBar}
    }
  }
''
