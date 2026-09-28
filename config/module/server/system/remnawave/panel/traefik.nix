{
  config,
  lib,
  ports,
  ...
}:
lib.mkIf config.services.remnawave-panel.enable {
  sops = {
    secrets."domain.remnawave.subscription" = {
      owner = "traefik";
    };

    templates."traefik-remnawave-subscription.yaml" = {
      path = "${config.services.traefik.dataDir}/dynamic/remnawave-subscription.yaml";
      owner = "traefik";
      mode = "0400";
      content = ''
        http:
          routers:
            remnawave-subscription:
              rule: "Host(`${config.sops.placeholder."domain.remnawave.subscription"}`)"
              entryPoints:
                - websecure
              service: remnawave-subscription
              tls:
                certResolver: letsencrypt

          services:
            remnawave-subscription:
              loadBalancer:
                servers:
                  - url: "http://127.0.0.1:${toString ports.remnawave.panel.subscription}"
      '';
    };
  };

  services.traefik.enable = true;
}
