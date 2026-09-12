{
  pkgs,
  ...
}:
{
  xdg.portal = {
    enable = true;

    config.common.default = "*";

    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };
}
