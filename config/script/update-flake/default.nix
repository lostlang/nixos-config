{
  lib,
  pkgs,
  ...
}:
let
  update-flake = pkgs.writeShellApplication {
    name = "update-flake";

    runtimeInputs = with pkgs; [
      fzf
      python3
    ];

    text = ''
      export PYTHONPATH=${./..}''${PYTHONPATH:+:$PYTHONPATH}

      exec ${lib.getExe pkgs.python3} ${./main.py} "$@"
    '';
  };
in
{
  environment.systemPackages = [ update-flake ];
}
