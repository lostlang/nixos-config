{
  lib,
  pkgs,
  user,
}:
let
  makeSandbox = import ../make-sandbox.nix { inherit lib pkgs; };
in
makeSandbox {
  inherit user;
  name = "pyright-sandbox";
  executable = lib.getExe' pkgs.pyright "pyright-langserver";
  sandboxDirectory = ".cache/sandbox/pyright";
  runtimeInputs = [ pkgs.python3 ];
}
