{
  colorScheme,
  osConfig,
  ...
}:
let
  palette = colorScheme.default.palette;
in
''
  layout {
    with_bars name="ai"{
      pane split_direction="vertical"{
        pane {
          command "codex"
        }
        pane {
          command "aiderw-zai"
        }
      }
    }
    with_bars name="lazygit"{
      pane split_direction="vertical"{
        pane {
          command "lazygit"
        }
      }
    }
    with_bars name="terminal"{
      pane split_direction="vertical"{
        pane {
          command "nix"
          args "develop"
        }
      }
    }

    tab_template name="with_bars"{
      children

      pane {
        size 1
        plugin location="zellij:status-bar"
      }
      pane {
        size 1
        plugin location="https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" {
          format_left   "#[bg=${palette.green},fg=${palette.light_white},bold]{mode}#[bg=${palette.gradient.dark.g2},fg=${palette.green}] #[bg=${palette.gradient.dark.g2},fg=${palette.light_white},bold] {session} #[fg=${palette.gradient.dark.g2}] {command_git_branch}"
          format_center " {tabs} "
          format_right  "{datetime}"

          mode_normal        " {name} "
          mode_locked        " {name} "
          mode_resize        " {name} "
          mode_pane          " {name} "
          mode_tab           " {name} "
          mode_scroll        " {name} "
          mode_enter_search  " {name} "
          mode_search        " {name} "
          mode_rename_tab    " {name} "
          mode_rename_pane   " {name} "
          mode_session       " {name} "
          mode_move          " {name} "
          mode_prompt        " {name} "
          mode_tmux          " {name} "

          tab_normal   "#[fg=${palette.light_blue}] {name} "
          tab_active   "#[fg=${palette.blue},bold,italic] {name} "

          command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
          command_git_branch_format      "#[fg=${palette.blue}]  {stdout} "
          command_git_branch_interval    "10"
          command_git_branch_rendermode  "static"

          datetime "#[bg=${palette.light_white},fg=${palette.green}] #[bg=${palette.green},fg=${palette.light_white}] {format} "
          datetime_format "%A, %H:%M"
          datetime_timezone "${osConfig.time.timeZone}"
        }
      }
    }
  }
''
