{
  config,
  lib,
  pkgs,
  pythonScriptEnv,
  user,
  ...
}:
let
  makeSandbox = import ../../core/home/make-sandbox/make-sandbox-wrapper.nix {
    inherit
      config
      lib
      pkgs
      pythonScriptEnv
      ;
  };
in
{
  home.packages = [
    pkgs.nixd
    (import ./python.nix {
      inherit
        config
        lib
        pkgs
        makeSandbox
        user
        ;
    })
    (import ./go.nix {
      inherit
        config
        lib
        pkgs
        makeSandbox
        user
        ;
    })
    (import ./rust.nix {
      inherit
        config
        lib
        pkgs
        makeSandbox
        user
        ;
    })
  ];
}
