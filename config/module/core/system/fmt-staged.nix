{
  lib,
  pkgs,
  pythonScriptEnv,
  ...
}:
let
  fmt-staged = pkgs.writeShellApplication {
    name = "fmt-staged";

    runtimeInputs = with pkgs; [
      git
      nix
      pythonScriptEnv
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "fmt-staged.py"} \
        --git-executable ${lib.getExe pkgs.git} \
        --nix-executable ${lib.getExe pkgs.nix} \
        "$@"
    '';
  };
in
{
  environment.systemPackages = [ fmt-staged ];
}
