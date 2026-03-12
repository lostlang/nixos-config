{
  colorScheme,
  lib,
  ...
}:
let
  config = import ./config.nix { inherit colorScheme; };
in
{
  imports = [
    ./script
  ];

  xdg.configFile = {
    "xdg-desktop-portal/niri-portals.conf".text = ''
      [preferred]
      default=gnome;gtk;
      org.freedesktop.impl.portal.ScreenCast=gnome;
      org.freedesktop.impl.portal.Settings=gnome;
      org.freedesktop.impl.portal.FileChooser=gtk;
    '';

    "niri/config.kdl".text = config;

    "niri/resolution".source = ./resolution;

    "niri/autoload.kdl".source = ./autoload.kdl;
    "niri/binds.kdl".source = ./binds.kdl;
    "niri/private.kdl".source = ./private.kdl;
    "niri/windowrule.kdl".source = ./windowrule.kdl;
  };

  home.activation.niriSymlink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sf "$HOME/.config/niri/resolution/monitor_16_9_1920_1080.kdl" \
      "$HOME/.config/niri/active-profile.kdl"
  '';
}
