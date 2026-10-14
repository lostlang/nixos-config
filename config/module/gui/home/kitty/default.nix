{
  config,
  colorScheme,
  ...
}:
let
  themeName = colorScheme.default.name;
  themeText = import ./theme.nix { inherit colorScheme; };
in
{
  stylix.targets.kitty.enable = false;

  programs.kitty = {
    enable = true;

    settings = {
      confirm_os_window_close = 0;
      remember_window_size = false;
      scrollback_pager = "nvim -c 'set buftype=nofile' -c 'set nomodifiable' -";

      font_family = config.stylix.fonts.monospace.name;
      bold_font = ''family="${config.stylix.fonts.monospace.name}" style=ExtraBold'';
      bold_italic_font = ''family="${config.stylix.fonts.monospace.name}" style="ExtraBold Italic"'';
      font_size = 14.0;

      include = "${themeName}.conf";
    };
  };

  xdg.configFile."kitty/${themeName}.conf".text = themeText;
}
