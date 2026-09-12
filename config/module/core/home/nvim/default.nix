{
  lib,
  nvimExtra,
  ...
}:
{
  imports = [
    ./core

    ./core.nix
    ./diagnostic.nix
    ./keymap.nix
  ]
  ++ lib.optional nvimExtra ./extra;

  stylix.targets.nixvim.enable = false;

  programs.nixvim = {
    enable = true;

    withRuby = nvimExtra;
    withNodeJs = nvimExtra;
    withPython3 = nvimExtra;

    nixpkgs.useGlobalPackages = true;
  };
}
