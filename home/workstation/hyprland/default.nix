{ pkgs, ... }:
{

  imports = [
    ./binds.nix
    ./autoload.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # The hyprland package to use
    package = pkgs.hyprland;
    # Whether to enable XWayland
    xwayland.enable = true;

    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;

    settings = {
      "$mainMod" = "SUPER";
      "$term" = "kitty";
      "$menu" = "wofi --show drun";
      monitor = ",preferred,auto,1";
    };
  };
}
