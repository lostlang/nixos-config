{
  config,
  lib,
  pkgs,
  pythonScriptEnv,
  ...
}:
let
  hypr-resolution-switch = pkgs.writeShellApplication {
    name = "hypr-resolution-switch";

    runtimeInputs = with pkgs; [
      fzf
      hyprland
      pythonScriptEnv
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "hypr-resolution-switch.py"} \
        --config-dir ${lib.escapeShellArg "${config.xdg.configHome}/hypr"} \
        --wallpaper-dir ${lib.escapeShellArg "${config.home.homeDirectory}/Pictures/Wallpapers"} \
        --generated-wallpaper-dir ${lib.escapeShellArg "${config.home.homeDirectory}/Pictures/GeneratedWallpapers"} \
        --fzf-executable ${lib.getExe pkgs.fzf} \
        --hyprctl-executable ${lib.getExe' pkgs.hyprland "hyprctl"} \
        "$@"
    '';
  };
in
{
  home.packages = [ hypr-resolution-switch ];
}
