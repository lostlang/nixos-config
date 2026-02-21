{
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
      scrollback_pager = "nvim -c 'set buftype=nofile' -c 'set nomodifiable' -";
      font_family = "JetBrainsMono Nerd Fonts";
      font_size = 14.0;
      include = "${themeName}.conf";
    };
  };

  xdg.configFile."kitty/${themeName}.conf".text = themeText;
}
