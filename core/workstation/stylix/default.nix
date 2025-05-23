{ pkgs, ... }:
{
  stylix = {
    enable = true;

    image = ./wallpaper.jpg;

    polarity = "light";

    base16Scheme = ./lostsand.yaml;

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Amber";
      size = 24;
    };

    homeManagerIntegration.autoImport = true;
  };
}
