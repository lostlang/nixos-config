{
  config,
  lib,
  pkgs,
  user,
  ...
}:
{
  options.lsp.enable = lib.mkEnableOption "language servers";

  config.environment.systemPackages = lib.mkIf config.lsp.enable [
    pkgs.nixd
    (import ./python.nix { inherit lib pkgs user; })
    (import ./go.nix { inherit lib pkgs user; })
    (import ./rust.nix { inherit lib pkgs user; })
  ];
}
