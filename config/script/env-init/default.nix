{
  lib,
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "env-init";

  runtimeInputs = with pkgs; [
    fzf
    git
    python3
  ];

  text = ''
    export PYTHONPATH=${./..}''${PYTHONPATH:+:$PYTHONPATH}

    exec ${lib.getExe pkgs.python3} ${./main.py} "$@"
  '';
}
