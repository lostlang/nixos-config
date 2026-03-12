{
  pkgs,
  ...
}:
{
  stylix = {
    image = ./wallpaper.jpg;

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Amber";
      size = 24;
    };
  };
}
