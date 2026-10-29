{
  config,
  lib,
  ports,
  ...
}:
lib.mkIf config.services.openbao.enable {
  sops = {
    secrets."domain.openbao" = {
      owner = "traefik";
    };

    templates."traefik-openbao.yaml" = {
      path = "${config.services.traefik.dataDir}/dynamic/openbao.yaml";
      owner = "traefik";
      mode = "0400";
      content = /* yaml */ ''
        http:
          routers:
            openbao:
              rule: "Host(`${config.sops.placeholder."domain.openbao"}`) && PathPrefix(`/v1/`)"
              entryPoints:
                - websecure
              service: openbao
              tls:
                certResolver: letsencrypt

          services:
            openbao:
              loadBalancer:
                servers:
                  - url: "http://127.0.0.1:${toString ports.openbao.api}"
      '';
    };
  };

  services.traefik.enable = true;
}
