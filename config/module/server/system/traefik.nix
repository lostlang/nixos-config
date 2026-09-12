{
  config,
  lib,
  ...
}:
{
  services.traefik = {
    enable = lib.mkDefault false;

    staticConfigOptions = {
      providers.file = {
        directory = "${config.services.traefik.dataDir}/dynamic";
        watch = true;
      };

      entryPoints = {
        dot.address = ":853";
        websecure.address = ":443";

        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };
      };

      certificatesResolvers.letsencrypt.acme = {
        storage = "/var/lib/traefik/acme.json";
        httpChallenge.entryPoint = "web";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    853
  ];
}
