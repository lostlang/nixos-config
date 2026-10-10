{
  lib,
  pkgs,
  zellij ? pkgs.zellij,
}:
pkgs.writeShellApplication {
  name = "zp";

  runtimeInputs = [
    zellij
    pkgs.git
    pkgs.python3
  ];

  text = ''
    export PYTHONPATH=${../../../../script}''${PYTHONPATH:+:$PYTHONPATH}

    exec ${lib.getExe pkgs.python3} ${../../../../script/zellij-project.py} \
      --zellij-executable zellij \
      --git-executable git \
      --layout code \
      "$@"
  '';
}
