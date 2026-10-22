{
  lib,
  pkgs,
  pythonScriptEnv,
}:
pkgs.writeShellApplication {
  name = "make-sandbox";

  runtimeInputs = [
    pkgs.bubblewrap
    pythonScriptEnv
  ];

  text = /* sh */ ''
    exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/make-sandbox.py \
      --bubblewrap-executable ${lib.getExe pkgs.bubblewrap} \
      --terminfo ${lib.escapeShellArg "${pkgs.ncurses}/share/terminfo"} \
      --ssl-cert-file ${lib.escapeShellArg "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"} \
      --ssl-cert-dir ${lib.escapeShellArg "${pkgs.cacert}/etc/ssl/certs"} \
      "$@"
  '';
}
