{
  config,
  lib,
  pkgs,
  makeSandbox,
  user,
}:
let
  goPath = "${config.home.homeDirectory}/go";
  goCache = "${config.xdg.cacheHome}/go-build";
in
makeSandbox {
  inherit user;
  name = "gopls-sandbox";
  executable = lib.getExe pkgs.gopls;
  sandboxDirectory = "${config.xdg.cacheHome}/sandbox/gopls";
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
