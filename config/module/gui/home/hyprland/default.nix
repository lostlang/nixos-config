{
  colorScheme,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./resolution_swich.nix ];

  stylix.targets.hyprland.enable = false;

  wayland.windowManager.hyprland = {
    enable = true;

    configType = "lua";
    xwayland.enable = true;

    systemd.enable = true;

    extraLuaFiles = {
      autoload = ./autoload.lua;
      config = ./config.lua;
      keymap = ./keymap.lua;
      private = ./private.lua;
      theme = pkgs.writeText "hyprland-theme.lua" (import ./theme.nix { inherit colorScheme; });
      windowrule = ./windowrule.lua;
    };
  };

  xdg.configFile."hypr/resolution".source = ./resolution;

  home.activation.hyprSymlink = lib.hm.dag.entryAfter [ "linkGeneration" ] /* sh */ ''
    if [ ! -e ${lib.escapeShellArg "${config.xdg.configHome}/hypr/active-profile.lua"} ]; then
      run ${lib.getExe' pkgs.coreutils "ln"} -sf \
        ${lib.escapeShellArg "${config.xdg.configHome}/hypr/resolution/default.lua"} \
        ${lib.escapeShellArg "${config.xdg.configHome}/hypr/active-profile.lua"}
    fi
  '';

  home.packages = with pkgs; [
    brightnessctl
    playerctl
    wireplumber
  ];
}
