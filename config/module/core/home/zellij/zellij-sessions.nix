{
  config,
  lib,
  pkgs,
  pythonScriptEnv,
  ...
}:
let
  zellij = config.programs.zellij.package;
  zs = pkgs.writeShellApplication {
    name = "zs";

    runtimeInputs = [
      zellij
      pkgs.fzf
      pythonScriptEnv
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "zellij-sessions.py"} \
        --fzf-executable ${lib.getExe pkgs.fzf} \
        --zellij-executable ${lib.getExe zellij} \
        "$@"
    '';
  };
in
{
  home.packages = lib.mkIf config.programs.zellij.enable [ zs ];
}
