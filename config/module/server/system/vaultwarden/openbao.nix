{
  config,
  lib,
  pkgs,
  ports,
  pythonScriptEnv,
  hostname,
  ...
}:
let
  addressArgument = import ../../openbao-address-argument.nix {
    inherit
      config
      lib
      pkgs
      ports
      ;
  };

  runtimeDirectory = "/run/vaultwarden-secrets";

  environmentFile = "${runtimeDirectory}/vaultwarden.env";
  environmentTemplate = pkgs.writeText "vaultwarden.env.template" /* ini */ ''
    ADMIN_TOKEN=$admin_token
  '';

  traefikFile = "${config.services.traefik.dataDir}/dynamic/vaultwarden.yaml";
  traefikTemplate = pkgs.writeText "traefik-vaultwarden.yaml.template" /* yaml */ ''
    http:
      routers:
        vaultwarden:
          rule: >-
            Host(`$domain`) &&
            !(Path(`/admin`) || PathPrefix(`/admin/`))
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

  fetchSecrets = pkgs.writeShellApplication {
    name = "vaultwarden-fetch-secrets";

    runtimeInputs = with pkgs; [
      coreutils
      pythonScriptEnv
    ];

    text = /* sh */ ''
      ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/openbao/render-template.py \
        --address ${addressArgument} \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString environmentTemplate)} \
        --output-file ${lib.escapeShellArg environmentFile} \
        --secret admin_token ${lib.escapeShellArg "server/${hostname}"} vaultwarden_admin_token

      ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/openbao/render-template.py \
        --address ${addressArgument} \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString traefikTemplate)} \
        --output-file ${lib.escapeShellArg "${runtimeDirectory}/traefik.yaml"} \
        --secret domain shared/domain vaultwarden

      install -d -m 0755 ${lib.escapeShellArg "${config.services.traefik.dataDir}/dynamic"}
      install -m 0400 -o traefik ${lib.escapeShellArg "${runtimeDirectory}/traefik.yaml"} ${lib.escapeShellArg "${traefikFile}.tmp"}
      mv -T ${lib.escapeShellArg "${traefikFile}.tmp"} ${lib.escapeShellArg traefikFile}
    '';
  };
in
lib.mkIf config.services.vaultwarden.enable {
  services.vaultwarden.environmentFile = [ environmentFile ];

  systemd.services.vaultwarden-secrets = {
    description = "Load Vaultwarden secrets from OpenBao";

    wantedBy = [ "multi-user.target" ];
    requires = [ "openbao-client-login.service" ];
    after = [ "openbao-client-login.service" ];
    before = [ "vaultwarden.service" ];
    unitConfig.StartLimitIntervalSec = 0;

    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "2min";
      ExecStart = lib.getExe fetchSecrets;
      ExecStartPost = "${lib.getExe' pkgs.systemd "systemctl"} --no-block start vaultwarden.service";
      RemainAfterExit = true;
      RuntimeDirectory = "vaultwarden-secrets";
      RuntimeDirectoryMode = "0700";
      RuntimeDirectoryPreserve = "restart";
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };

  systemd.services.vaultwarden = {
    partOf = [ "vaultwarden-secrets.service" ];
    requires = [ "vaultwarden-secrets.service" ];
    after = [ "vaultwarden-secrets.service" ];
  };
}
