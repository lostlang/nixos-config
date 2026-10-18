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
      nix
      python3
    ];

    text = /* sh */ ''
      export PYTHONPATH=${../../../../script}''${PYTHONPATH:+:$PYTHONPATH}

      exec ${lib.getExe pkgs.python3} ${../../../../script/fmt-staged.py} \
        --git-executable ${lib.getExe pkgs.git} \
        --nix-executable ${lib.getExe pkgs.nix} \
        "$@"
    '';
  };
in
{
  environment.systemPackages = [ fmt-staged ];
}
