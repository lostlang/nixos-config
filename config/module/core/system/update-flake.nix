{
  lib,
  pkgs,
  ...
}:
let
  update-flake = pkgs.writeShellApplication {
    name = "update-flake";

    runtimeInputs = with pkgs; [
      fzf
      nix
      python3
    ];

    text = /* sh */ ''
      export PYTHONPATH=${../../../../script}''${PYTHONPATH:+:$PYTHONPATH}

      exec ${lib.getExe pkgs.python3} ${../../../../script/update-flake.py} \
        --nix-executable ${lib.getExe pkgs.nix} \
        --fzf-executable ${lib.getExe pkgs.fzf} \
        "$@"
    '';
  };
in
{
  environment.systemPackages = [ update-flake ];
}
