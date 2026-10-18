{
  lib,
  pkgs,
  zellij ? pkgs.zellij,
}:
pkgs.writeShellApplication {
  name = "zs";

  runtimeInputs = [
    zellij
    pkgs.fzf
    pkgs.python3
  ];

  text = /* sh */ ''
    export PYTHONPATH=${../../../../../script}''${PYTHONPATH:+:$PYTHONPATH}

    exec ${lib.getExe pkgs.python3} ${../../../../../script/zellij-sessions.py} \
      --fzf-executable ${lib.getExe pkgs.fzf} \
      --zellij-executable ${lib.getExe zellij} \
      "$@"
  '';
}
