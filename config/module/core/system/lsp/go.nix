{
  lib,
  pkgs,
  user,
}:
let
  makeSandbox = import ../make-sandbox.nix { inherit lib pkgs; };
  goPath = "/home/${user}/go";
  goCache = "/home/${user}/.cache/go-build";
in
makeSandbox {
  inherit user;
  name = "gopls-sandbox";
  executable = lib.getExe pkgs.gopls;
  sandboxDirectory = ".cache/sandbox/gopls";
  runtimeInputs = with pkgs; [
    go
  ];

  hostEnvPassthrough = [ ];
  directories = [
    goPath
    goCache
  ];
  binds = [
    {
      source = goPath;
      target = goPath;
    }
    {
      source = goCache;
      target = goCache;
    }
  ];
  environment = {
    GOPATH = goPath;
    GOCACHE = goCache;
  };
}
