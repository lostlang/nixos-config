{
  config,
  colorScheme,
  lib,
  user,
  ...
}:
let
  themeName = colorScheme.default.name;
  inherit (colorScheme.default) palette;
in
{
  home-manager.sharedModules = lib.mkIf (!config.stylix.enable) [
    config.stylix.homeManagerIntegration.module
  ];

  stylix = {
    enable = lib.mkDefault false;

    # homeManagerIntegration.autoImport = true;

    polarity = "light";
    base16Scheme = {
      scheme = "${themeName}";
      author = "${user}";
      base00 = "${palette.light_white}";
      base01 = "${palette.light_white}";
      base02 = "${palette.white}";
      base03 = "${palette.light_blue}";
      base04 = "${palette.black}";
      base05 = "${palette.black}";
      base06 = "${palette.light_black}";
      base07 = "${palette.light_white}";
      base08 = "${palette.red}";
      base09 = "${palette.orange}";
      base0A = "${palette.yellow}";
      base0B = "${palette.green}";
      base0C = "${palette.aqua}";
      base0D = "${palette.blue}";
      base0E = "${palette.purple}";
      base0F = "${palette.gradient.dark.g3}";
    };
  };
}
