{ pkgs, ... }:
{
  imports = [
    ./autoload.nix
    ./binds.nix
    ./windowrule.nix
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
      monitor = [
        "HDMI-A-1, 1920x1080@60, 0x0, 1"
        "HDMI-A-2, 1920x1080@60, 0x0, 1, mirror, HDMI-A-1"
      ];
    };
  };
}
