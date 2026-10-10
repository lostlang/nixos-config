{
  colorScheme,
  osConfig,
  zjstatus,
}:
let
  inherit (colorScheme.default) palette;

  background = palette.gradient.dark.g2;

  style = {
    mode = "#[bg=${palette.green},fg=${palette.light_white},bold]";
    modeSeparator = "#[bg=${background},fg=${palette.green}]";
    session = "#[bg=${background},fg=${palette.light_white},bold]";
    sessionSeparator = "#[fg=${background}]";
    tabNormal = "#[fg=${palette.light_blue},bold]";
    tabActive = "#[fg=${palette.blue},bold,italic]";
    gitBranch = "#[fg=${palette.blue}]";
    datetimeSeparator = "#[bg=${palette.light_white},fg=${palette.green}]";
    datetime = "#[bg=${palette.green},fg=${palette.light_white}]";
  };
in
''
  pane size=1 {
    plugin location="file:${zjstatus}/bin/zjstatus.wasm" {
      format_left   "${style.mode} {mode} ${style.modeSeparator}${style.session} {session} ${style.sessionSeparator} {command_git_branch} "
      format_center "{tabs}"
      format_right  "{datetime}"

      mode_normal "{name}"

      tab_normal    "${style.tabNormal}{name}"
      tab_active    "${style.tabActive}{name}"
      tab_separator " "

      command_git_branch_command    "git rev-parse --abbrev-ref HEAD"
      command_git_branch_format     "${style.gitBranch} {stdout} "
      command_git_branch_interval   "10"
      command_git_branch_rendermode "static"

      datetime          "${style.datetimeSeparator}${style.datetime} {format} "
      datetime_format   "%A %H:%M"
      datetime_timezone "${osConfig.time.timeZone}"
    }
  }
''
