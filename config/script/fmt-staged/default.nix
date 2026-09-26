{
  lib,
  pkgs,
  ...
}:
let
  fmt-staged = pkgs.writeShellApplication {
    name = "fmt-staged";

    runtimeInputs = with pkgs; [
      git
      python3
    ];

    text = ''
      exec ${lib.getExe pkgs.python3} ${./main.py} "$@"
    '';
  };
in
{
  environment.systemPackages = [ fmt-staged ];
}
