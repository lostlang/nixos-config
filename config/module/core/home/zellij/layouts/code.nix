{
  colorScheme,
  osConfig,
  zjstatus,
  ...
}:
let
  statusBar = import ../status-bar.nix {
    inherit colorScheme osConfig zjstatus;
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
    tab name="agent" {
      pane {
        command "codex"
      }
    }
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
