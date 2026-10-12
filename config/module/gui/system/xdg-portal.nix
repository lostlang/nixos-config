{
  pkgs,
  ...
}:
{
  xdg.portal = {
    enable = true;

    config = {
      common.default = [
        "hyprland"
        "gtk"
      ];
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
