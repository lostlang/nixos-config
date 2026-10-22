{
  lib,
  pkgs,
  pythonScriptEnv,
  zellij ? pkgs.zellij,
}:
pkgs.writeShellApplication {
  name = "zs";

  runtimeInputs = [
    zellij
    pkgs.fzf
    pythonScriptEnv
  ];

  text = /* sh */ ''
    exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/zellij-sessions.py \
      --fzf-executable ${lib.getExe pkgs.fzf} \
      --zellij-executable ${lib.getExe zellij} \
      "$@"
  '';
}
