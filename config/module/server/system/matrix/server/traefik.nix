{
  config,
  lib,
  ports,
  ...
}:
lib.mkIf config.services.matrix-tuwunel.enable {
  sops.templates."traefik-tuwunel.yaml" = {
    path = "${config.services.traefik.dataDir}/dynamic/tuwunel.yaml";
    owner = "traefik";
    content = /* yaml */ ''
      http:
        routers:
          tuwunel:
            rule: "Host(`${config.sops.placeholder."domain.matrix.server"}`)"
            entryPoints:
              - websecure
            service: tuwunel
            tls:
              certResolver: letsencrypt

        services:
          tuwunel:
            loadBalancer:
              servers:
                - url: "http://127.0.0.1:${toString ports.matrix.server}"
    '';
  };

  services.traefik.enable = true;
}
