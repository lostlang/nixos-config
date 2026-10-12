{
  colorScheme,
  lib,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    xwayland.enable = true;

    systemd.enable = true;

    extraLuaFiles = {
      config = ./config.lua;
      autoload = ./autoload.lua;
      binds = ./binds.lua;
      private = ./private.lua;
      theme = pkgs.writeText "hyprland-theme.lua" (import ./theme.nix { inherit colorScheme; });
      windowrule = ./windowrule.lua;
    };
  };

  xdg.configFile."hypr/resolution".source = ./resolution;

  home.activation.hyprSymlink = lib.hm.dag.entryAfter [ "writeBoundary" ] /* sh */ ''
    if [ ! -e "$HOME/.config/hypr/active-profile.lua" ]; then
      ln -sf "$HOME/.config/hypr/resolution/default.lua" \
        "$HOME/.config/hypr/active-profile.lua"
    fi
  '';

  home.packages = [
    (import ./resolution_swich.nix { inherit lib pkgs; })
  ]
  ++ (with pkgs; [
    brightnessctl
    playerctl
    wireplumber
  ]);
}
