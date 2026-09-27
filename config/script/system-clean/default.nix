{
  config,
  lib,
  pkgs,
  ...
}:
let
  system-clean = pkgs.writeShellApplication {
    name = "system-clean";

    runtimeInputs = with pkgs; [
      fzf
      python3
    ];

    text = ''
      export PYTHONPATH=${./..}''${PYTHONPATH:+:$PYTHONPATH}

      exec ${lib.getExe pkgs.python3} ${./main.py} \
        ${lib.optionalString config.programs.nixvim.enable "--nvim"} \
        ${lib.optionalString config.programs.zellij.enable "--zellij"} \
        "$@"
    '';
  };
in
{
  home.packages = [ system-clean ];
}
