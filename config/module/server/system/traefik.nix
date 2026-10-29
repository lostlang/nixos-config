{
  config,
  lib,
  pkgs,
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

  systemd.services.traefik = lib.mkIf config.services.traefik.enable {
    # HACK:
    # SOPS can leave links to templates removed from the configuration.
    # Restart on manifest changes so cleanup also runs when services are removed.
    restartTriggers = [ config.system.build.sops-nix-manifest ];
    after = lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";
    requires = lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";
    serviceConfig.ExecStartPre = lib.mkBefore [
      "+${pkgs.writeShellScript "traefik-cleanup-dynamic" ''
        set -eu
        dynamicDir=${lib.escapeShellArg "${config.services.traefik.dataDir}/dynamic"}
        if [ -d "$dynamicDir" ]; then
          ${pkgs.findutils}/bin/find -P "$dynamicDir" -maxdepth 1 \
            -type l -xtype l -print -delete
        fi
      ''}"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    853
  ];
}
