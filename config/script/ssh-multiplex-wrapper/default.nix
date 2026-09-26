{
  lib,
  hostname,
  pkgs,
  user,
  ...
}:
let
  session-name = "ssh-${user}-${hostname}";
in
pkgs.writeShellApplication {
  name = "ssh-multiplex-wrapper";

  runtimeInputs = with pkgs; [
    openssh
    python3
  ];

  text = ''
    exec ${lib.getExe pkgs.python3} ${./main.py} \
      --session-name ${lib.escapeShellArg session-name} \
      -- "$@"
  '';
}
