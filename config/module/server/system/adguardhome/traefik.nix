{
  config,
  dnsPort,
  lib,
  webPort,
  ...
}:
lib.mkIf config.services.adguardhome.enable {
  sops = {
    secrets."domain.adguardhome" = {
      owner = "traefik";
    };

    templates."traefik-adguardhome.yaml" = {
      path = "${config.services.traefik.dataDir}/dynamic/adguardhome.yaml";
      owner = "traefik";
      mode = "0400";
      content = ''
        http:
          routers:
            adguardhome:
              rule: "Host(`${config.sops.placeholder."domain.adguardhome"}`) && Path(`/dns-query`)"
              entryPoints:
                - websecure
              service: adguardhome
              tls:
                certResolver: letsencrypt

          services:
            adguardhome:
              loadBalancer:
                servers:
                  - url: "http://127.0.0.1:${toString webPort}"

        tcp:
          routers:
            adguardhome-dot:
              entryPoints:
                - dot
              rule: "HostSNI(`${config.sops.placeholder."domain.adguardhome"}`)"
              service: adguardhome-dns
              tls:
                certResolver: letsencrypt

          services:
            adguardhome-dns:
              loadBalancer:
                servers:
                  - address: "127.0.0.1:${toString dnsPort}"
      '';
    };
  };

  services.traefik = {
    enable = true;
  };
}
