{
  colorScheme,
  ...
}:
let
  themeName = colorScheme.default.name;
  themeText = import ./theme.nix { inherit colorScheme; };
in
{
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      font_family = "JetBrainsMono Nerd Fonts";
      font_size = 14.0;
      include = "${themeName}.conf";
    };
  };

  home.file.".config/kitty/${themeName}.conf".text = themeText;
}
