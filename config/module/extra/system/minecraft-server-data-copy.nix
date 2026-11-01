{
  config,
  lib,
  pkgs,
  pythonScriptEnv,
  ...
}:
let
  minecraft-data-copy = pkgs.writeShellApplication {
    name = "minecraft-data-copy";

    runtimeInputs = [ pythonScriptEnv ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "minecraft-server-data-copy.py"} "$@"
    '';
  };
in
{
  options.programs.minecraft-data-copy.enable = lib.mkEnableOption "Minecraft server data copying";

  config = {
    programs.minecraft-data-copy.enable = lib.mkDefault false;
    environment.systemPackages = lib.mkIf config.programs.minecraft-data-copy.enable [
      minecraft-data-copy
    ];
  };
}
