{
  config,
  lib,
  pkgs,
  pythonScriptEnv,
  ...
}:
let
  zellij = config.programs.zellij.package;
  zp = pkgs.writeShellApplication {
    name = "zp";

    runtimeInputs = [
      zellij
      pythonScriptEnv
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "zellij-project.py"} \
        --zellij-executable ${lib.getExe zellij} \
        --config-dir ${lib.escapeShellArg "${config.xdg.configHome}/zellij"} \
        --layout code \
        "$@"
    '';
  };
in
{
  home.packages = lib.mkIf config.programs.zellij.enable [ zp ];
}
