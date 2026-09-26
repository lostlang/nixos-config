{
  programs,
  lib,
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "system-clean";

  runtimeInputs = with pkgs; [
    fzf
    python3
  ];

  text = ''
    export PYTHONPATH=${./..}''${PYTHONPATH:+:$PYTHONPATH}

    exec ${lib.getExe pkgs.python3} ${./main.py} \
      ${lib.optionalString programs.nixvim.enable "--nvim"} \
      ${lib.optionalString programs.zellij.enable "--zellij"} \
      "$@"
  '';
}
