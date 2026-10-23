{
  lib,
  pkgs,
  pythonScriptEnv,
  user,
  ...
}:
let
  update-flake = pkgs.writeShellApplication {
    name = "update-flake";

    runtimeInputs = with pkgs; [
      fzf
      nix
      pythonScriptEnv
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/update-flake.py \
        --config-dir ${lib.escapeShellArg "/home/${user}/.config/nixos"} \
        --nix-executable ${lib.getExe pkgs.nix} \
        --fzf-executable ${lib.getExe pkgs.fzf} \
        "$@"
    '';
  };
in
{
  environment.systemPackages = [ update-flake ];
}
