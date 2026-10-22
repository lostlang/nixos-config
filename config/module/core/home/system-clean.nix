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

    runtimeInputs = with pkgs; [
      fzf
      nix
      pythonScriptEnv
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/system-clean.py \
        --fzf-executable ${lib.getExe pkgs.fzf} \
        --sudo-executable ${lib.escapeShellArg "${osConfig.security.wrapperDir}/sudo"} \
        --nix-collect-garbage-executable ${lib.getExe' pkgs.nix "nix-collect-garbage"} \
        ${lib.optionalString config.programs.nixvim.enable "--nvim"} \
        ${lib.optionalString config.programs.zellij.enable "--zellij-executable ${lib.getExe pkgs.zellij}"} \
        "$@"
    '';
  };
in
{
  home.packages = [ system-clean ];
}
