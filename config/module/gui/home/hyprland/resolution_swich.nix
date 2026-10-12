{
  lib,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "hypr-resolution-switch";

  runtimeInputs = with pkgs; [
    fzf
    hyprland
    python3
  ];

  text = /* sh */ ''
    export PYTHONPATH=${../../../../script}''${PYTHONPATH:+:$PYTHONPATH}

    exec ${lib.getExe pkgs.python3} ${../../../../script/hypr-resolution-switch.py} "$@"
  '';
}
