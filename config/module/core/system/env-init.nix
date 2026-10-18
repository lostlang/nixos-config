{
  lib,
  pkgs,
  ...
}:
let
  env-init = pkgs.writeShellApplication {
    name = "env-init";

    runtimeInputs = with pkgs; [
      fzf
      git
      python3
    ];

    text = /* sh */ ''
      export PYTHONPATH=${../../../../script}''${PYTHONPATH:+:$PYTHONPATH}

      exec ${lib.getExe pkgs.python3} ${../../../../script/env-init.py} \
        --git-executable ${lib.getExe pkgs.git} \
        --fzf-executable ${lib.getExe pkgs.fzf} \
        "$@"
    '';
  };
in
{
  environment.systemPackages = [ env-init ];
}
