{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./autoload.nix
    ./binds.nix
    ./windowrule.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    systemd.enable = true;

    settings = {
      "$mainMod" = "SUPER";
      "$term" = "kitty";
      "$menu" = "wofi --show drun";
      source = [ "~/.config/hypr/active-profile.conf" ];
    };
  };

  xdg.configFile."hypr/resolution".source = ./resolution;

  home.activation.hyprSymlink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sf "$HOME/.config/hypr/resolution/monitor_16_9_1920_1080.conf" \
      "$HOME/.config/hypr/active-profile.conf"
  '';

  home.packages = [
    (import ./resolution_swich.nix { inherit pkgs; })
  ];
}
