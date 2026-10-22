{
  lib,
  pkgs,
  makeSandbox,
  user,
}:
makeSandbox {
  inherit user;
  name = "pyright-sandbox";
  executable = lib.getExe' pkgs.pyright "pyright-langserver";
  sandboxDirectory = ".cache/sandbox/pyright";
  runtimeInputs = [ pkgs.python3 ];
}
