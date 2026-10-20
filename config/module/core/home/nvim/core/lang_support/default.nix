{
  lib,
  ...
}:
{
  imports = [
    ./csv.nix
    ./md.nix
  ];

  programs.nixvim.extraConfigLua = lib.concatMapStringsSep "\n" builtins.readFile [
    ./html.lua
    ./nix.lua
  ];
}
