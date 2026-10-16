{
  lib,
  nvimExtra,
  ...
}:
{
  imports = [
    ./command
    ./core

    ./core.nix
    ./keymap.nix
  ]
  ++ lib.optional nvimExtra ./extra;

  stylix.targets.nixvim.enable = false;

  programs.nixvim = {
    enable = true;

    nixpkgs.useGlobalPackages = true;
  };
}
