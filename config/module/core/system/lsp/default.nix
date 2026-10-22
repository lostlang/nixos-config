{
  config,
  lib,
  pkgs,
  pythonScriptEnv,
  user,
  ...
}:
let
  makeSandbox = import ../make-sandbox/make-sandbox-wrapper.nix { inherit lib pkgs pythonScriptEnv; };
in
{
  options.lsp.enable = lib.mkEnableOption "language servers";

  config.environment.systemPackages = lib.mkIf config.lsp.enable [
    pkgs.nixd
    (import ./python.nix {
      inherit
        lib
        pkgs
        makeSandbox
        user
        ;
    })
    (import ./go.nix {
      inherit
        lib
        pkgs
        makeSandbox
        user
        ;
    })
    (import ./rust.nix {
      inherit
        lib
        pkgs
        makeSandbox
        user
        ;
    })
  ];
}
