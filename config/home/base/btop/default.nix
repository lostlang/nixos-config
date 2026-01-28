{
  colorScheme,
  user,
  ...
}:
let
  themeName = colorScheme.default.name;
  theme = import ./theme.nix { inherit colorScheme user; };
in
{
  stylix.targets.btop.enable = false;

  programs.btop = {
    enable = true;

    settings = {
      color_theme = themeName;
      theme_background = false;
      presets = "cpu:1:default,proc:0:default cpu:1:default,mem:0:tty cpu:1:default,net:0:tty";
    };
  };

  home.file.".config/btop/themes/${themeName}.theme".text = theme;
}
