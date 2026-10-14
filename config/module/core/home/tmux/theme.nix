{
  colorScheme,
  pkgs,
  ...
}:
let
  inherit (colorScheme.default) palette;
  background = palette.light_white;
  sectionBackground = palette.gradient.dark.g2;

  style = {
    section1 = "#[bg=${palette.green},fg=${palette.light_white},bold,noitalics]";
    separator1 = "#[bg=${sectionBackground},fg=${palette.green},nobold,noitalics]";

    section2 = "#[bg=${sectionBackground},fg=${palette.light_white},bold,noitalics]";
    separator2 = "#[bg=${background},fg=${sectionBackground},nobold,noitalics]";

    section3 = "#[bg=${palette.green},fg=${palette.light_white},bold,noitalics]";
    separator3 = "#[bg=${background},fg=${palette.green},nobold,noitalics]";

    tabNormal = "#[bg=${background},fg=${palette.blue},bold,noitalics]";
  };

  mode = "#{?client_prefix,Prefix,#{?pane_in_mode,Copy,Normal}}";
  gitBranch = "#(${pkgs.git}/bin/git -C #{q:pane_current_path} symbolic-ref --short HEAD 2>/dev/null)";
in
''
  set-option -g message-style 'bg=${palette.green},fg=${palette.light_white},bold'
  set-option -g message-command-style 'bg=${sectionBackground},fg=${palette.light_white},bold'
  set-option -g message-format '#[#{?command_prompt,#{message-command-style},#{message-style}},align=left,fill=#{?command_prompt,${sectionBackground},${palette.green}}]#{message}'

  set-option -g menu-style 'bg=${background},fg=${palette.blue}'
  set-option -g menu-selected-style 'bg=${palette.green},fg=${palette.light_white},bold'
  set-option -g menu-border-style 'bg=${background},fg=${palette.green}'

  set-option -g status-position bottom
  set-option -g status-interval 10
  set-option -g status-justify absolute-centre
  set-option -g status-style 'bg=${background},fg=${palette.blue}'
  set-option -g status-left-length 100
  set-option -g status-right-length 100

  set-option -g status-left '${style.section1} ${mode} ${style.separator1} ${style.section2}  ${gitBranch} ${style.separator2} '
  set-option -g status-right '${style.separator3} ${style.section3} #S '

  set-window-option -g window-status-format '${style.tabNormal}   #W   '
  set-window-option -g window-status-current-format '${style.separator3} ${style.section3} #W ${style.separator3} '
  set-window-option -g window-status-separator ' '
''
