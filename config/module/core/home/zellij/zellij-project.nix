{
  lib,
  pkgs,
  zellij ? pkgs.zellij,
}:
pkgs.writeShellApplication {
  name = "zp";

  runtimeInputs = [
    zellij
    pkgs.python3
  ];

  text = /* sh */ ''
    export PYTHONPATH=${../../../../../script}''${PYTHONPATH:+:$PYTHONPATH}

    exec ${lib.getExe pkgs.python3} ${../../../../../script/zellij-project.py} \
      --zellij-executable ${lib.getExe zellij} \
      --layout code \
      "$@"
  '';
}
