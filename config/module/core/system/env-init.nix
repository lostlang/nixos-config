{
  lib,
  pkgs,
  pythonScriptEnv,
  user,
  ...
}:
let
  env-init = pkgs.writeShellApplication {
    name = "env-init";

    runtimeInputs = with pkgs; [
      fzf
      git
      pythonScriptEnv
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "env-init.py"} \
        --env-dir ${lib.escapeShellArg "/home/${user}/.config/nixos/env"} \
        --git-executable ${lib.getExe pkgs.git} \
        --fzf-executable ${lib.getExe pkgs.fzf} \
        "$@"
    '';
  };
in
{
  environment.systemPackages = [ env-init ];
}
