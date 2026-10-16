{
  config,
  lib,
  pkgs,
  ports,
  ...
}:
let
  cfg = config.services.remnawave-node;
  webService = import ../../../../web-service.nix { inherit lib pkgs; };
in
{
  imports = [
    ./sops.nix
  ];

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (webService {
        name = "remnawave-node-mask";
        package = ./static;
        port = ports.remnawave.mask.backend;
      })
      {
        systemd.services.remnawave-node-mask.after = [ "remnawave-node.service" ];

        services.traefik = {
          enable = true;

          staticConfigOptions.entryPoints = {
            web.http.redirections.entryPoint.to = lib.mkForce ":443";

            websecure = {
              address = lib.mkForce "127.0.0.1:${toString ports.remnawave.mask.entryPoint}";
              proxyProtocol.trustedIPs = [ "127.0.0.1/32" ];
            };
          };
        };
      }
    ]
  );
}
