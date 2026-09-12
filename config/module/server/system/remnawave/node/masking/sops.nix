{
  config,
  lib,
  remnawave,
  ...
}:
let
  cfg = config.services.remnawave-node;
  domainSecret = "domain.remnawave.node.${config.networking.hostName}";
in
{
  sops = lib.mkIf cfg.enable {
    secrets.${domainSecret} = {
      owner = "traefik";
    };

    templates."traefik-remnawave-node-mask.yaml" = {
      path = "${config.services.traefik.dataDir}/dynamic/remnawave-node-mask.yaml";
      owner = "traefik";
      mode = "0400";
      content = ''
        http:
          routers:
            remnawave-node-mask:
              rule: "Host(`${config.sops.placeholder.${domainSecret}}`)"
              entryPoints:
                - websecure
              service: remnawave-node-mask
              tls:
                certResolver: letsencrypt

          services:
            remnawave-node-mask:
              loadBalancer:
                servers:
                  - url: "http://127.0.0.1:${toString remnawave.mask.backend.port}"
      '';
    };
  };
}
