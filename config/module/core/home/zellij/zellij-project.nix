{
  lib,
  pkgs,
  pythonScriptEnv,
  zellij ? pkgs.zellij,
}:
pkgs.writeShellApplication {
  name = "zp";

  runtimeInputs = [
    zellij
    pythonScriptEnv
  ];

  text = /* sh */ ''
    exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/zellij-project.py \
      --zellij-executable ${lib.getExe zellij} \
      --layout code \
      "$@"
  '';
}
