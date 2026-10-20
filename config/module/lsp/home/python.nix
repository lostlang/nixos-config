{
  config,
  lib,
  pkgs,
  makeSandbox,
  user,
}:
makeSandbox {
  inherit user;
  name = "pyright-sandbox";
  executable = lib.getExe' pkgs.pyright "pyright-langserver";
  sandboxDirectory = "${config.xdg.cacheHome}/sandbox/pyright";
  runtimeInputs = [ pkgs.python3 ];
}
