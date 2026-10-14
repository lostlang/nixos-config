{
  colorScheme,
  zjstatus,
}:
let
  inherit (colorScheme.default) palette;

  background = palette.gradient.dark.g2;

  style = {
    section1 = "#[bg=${palette.green},fg=${palette.light_white},bold]";
    separator1 = "#[bg=${background},fg=${palette.green}]";

    section2 = "#[bg=${background},fg=${palette.light_white},bold]";
    separator2 = "#[fg=${background}]";

    section3 = "#[bg=${palette.green},fg=${palette.light_white},bold]";
    separator3 = "#[fg=${palette.green}]";

    tabNormal = "#[fg=${palette.blue},bold]";
    tabActive = "#[fg=${palette.green},bold]";
  };
in
''
  pane size=1 {
    plugin location="file:${zjstatus}/bin/zjstatus.wasm" {
      format_left   "${style.section1} {mode} ${style.separator1} ${style.section2} {command_git_branch} ${style.separator2} "
      format_center "{tabs}"
      format_right  "${style.separator3} ${style.section3} {session} "

      format_hide_on_overlength "true"
      format_precedence "clr"

      mode_normal "{name}"

      tab_normal    "${style.tabNormal}   {name}   "
      tab_active    "${style.separator3} ${style.section3} {name} ${style.separator3} "

      command_git_branch_command    "git rev-parse --abbrev-ref HEAD"
      command_git_branch_format     " {stdout}"
      command_git_branch_interval   "10"
      command_git_branch_rendermode "static"
    }
  }
''
