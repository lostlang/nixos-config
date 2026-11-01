{
  config,
  lib,
  pkgs,
  ports,
  pythonScriptEnv,
  ...
}:
let
  runtimeDirectory = "/run/adguardhome-secrets";

  traefikFile = "${config.services.traefik.dataDir}/dynamic/adguardhome.yaml";
  traefikTemplate = pkgs.writeText "traefik-adguardhome.yaml.template" /* yaml */ ''
    http:
      routers:
        adguardhome:
          rule: "Host(`$domain`) && Path(`/dns-query`)"
          entryPoints:
            - websecure
          service: adguardhome
          tls:
            certResolver: letsencrypt

      services:
        adguardhome:
          loadBalancer:
            servers:
              - url: "http://127.0.0.1:${toString ports.adguardhome.web}"

    tcp:
      routers:
        adguardhome-dot:
          entryPoints:
            - dot
          rule: "HostSNI(`$domain`)"
          service: adguardhome-dns
          tls:
            certResolver: letsencrypt

      services:
        adguardhome-dns:
          loadBalancer:
            servers:
              - address: "127.0.0.1:${toString ports.adguardhome.dns}"
  '';

  fetchSecrets = pkgs.writeShellApplication {
    name = "adguardhome-fetch-secrets";

    runtimeInputs = with pkgs; [
      coreutils
      pythonScriptEnv
    ];

    text = /* sh */ ''
      ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/openbao/render-template.py \
        --address "https://$(${lib.getExe' pkgs.coreutils "cat"} ${
          lib.escapeShellArg config.sops.secrets."openbao.domain".path
        })" \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString traefikTemplate)} \
        --output-file ${lib.escapeShellArg "${runtimeDirectory}/traefik.yaml"} \
        --secret domain shared/domain adguardhome

      install -d -m 0755 ${lib.escapeShellArg "${config.services.traefik.dataDir}/dynamic"}
      install -m 0400 -o traefik ${lib.escapeShellArg "${runtimeDirectory}/traefik.yaml"} ${lib.escapeShellArg "${traefikFile}.tmp"}
      mv -T ${lib.escapeShellArg "${traefikFile}.tmp"} ${lib.escapeShellArg traefikFile}
    '';
  };
in
lib.mkIf config.services.adguardhome.enable {
  systemd.services.adguardhome-secrets = {
    description = "Load AdGuard Home secrets from OpenBao";

    wantedBy = [ "multi-user.target" ];
    requires = [ "openbao-client-login.service" ];
    after = [ "openbao-client-login.service" ];
    unitConfig.StartLimitIntervalSec = 0;

    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe fetchSecrets;
      RemainAfterExit = true;
      RuntimeDirectory = "adguardhome-secrets";
      RuntimeDirectoryMode = "0700";
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };
}
