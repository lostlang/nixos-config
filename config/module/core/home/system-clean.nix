{
  config,
  lib,
  osConfig,
  pkgs,
  pythonScriptEnv,
  ...
}:
let
  system-clean = pkgs.writeShellApplication {
    name = "system-clean";

    runtimeInputs = [
      pkgs.fzf
      pkgs.nix
      pythonScriptEnv
    ]
    ++ lib.optional config.programs.zellij.enable config.programs.zellij.package;

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "system-clean.py"} \
        --fzf-executable ${lib.getExe pkgs.fzf} \
        --sudo-executable ${lib.escapeShellArg "${osConfig.security.wrapperDir}/sudo"} \
        --nix-collect-garbage-executable ${lib.getExe' pkgs.nix "nix-collect-garbage"} \
        ${lib.optionalString config.programs.nixvim.enable "--nvim"} \
        ${lib.optionalString config.programs.zellij.enable "--zellij-executable ${lib.getExe config.programs.zellij.package}"} \
        "$@"
    '';
  };
in
{
  home.packages = [ system-clean ];
}
