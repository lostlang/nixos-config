{
  lib,
  ...
}:
{
  programs.nixvim.extraConfigLua = lib.concatMapStringsSep "\n" builtins.readFile [
    ./copy-context.lua
    ./smart-sort.lua
  ];
}
