{
  config,
  lib,
  ports,
  ...
}:
lib.mkIf (config.services.matrix-tuwunel.enable && config.services.matrix.client.enable) {
  sops = {
    secrets."domain.matrix.web" = { };

    templates."traefik-element-web.yaml" = {
      path = "${config.services.traefik.dataDir}/dynamic/element-web.yaml";
      owner = "traefik";
      content = /* yaml */ ''
        http:
          routers:
            element-web:
              rule: "Host(`${config.sops.placeholder."domain.matrix.web"}`)"
              entryPoints:
                - websecure
              service: element-web
              tls:
                certResolver: letsencrypt

          services:
            element-web:
              loadBalancer:
                servers:
                  - url: "http://127.0.0.1:${toString ports.matrix.client}"
      '';
    };
  };

  services.traefik.enable = true;
}
