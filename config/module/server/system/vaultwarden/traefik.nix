{
  config,
  lib,
  ports,
  ...
}:
lib.mkIf config.services.vaultwarden.enable {
  sops = {
    secrets."domain.vaultwarden" = {
      owner = "traefik";
    };

    templates."traefik-vaultwarden.yaml" = {
      path = "${config.services.traefik.dataDir}/dynamic/vaultwarden.yaml";
      owner = "traefik";
      mode = "0400";
      content = ''
        http:
          routers:
            vaultwarden:
              rule: "Host(`${config.sops.placeholder."domain.vaultwarden"}`)"
              entryPoints:
                - websecure
              service: vaultwarden
              tls:
                certResolver: letsencrypt

          services:
            vaultwarden:
              loadBalancer:
                servers:
                  - url: "http://127.0.0.1:${toString ports.vaultwarden}"
      '';
    };
  };

  services.traefik.enable = true;
}
