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

  runtimeDirectory = "/run/tuwunel-secrets";

  environmentFile = "${runtimeDirectory}/tuwunel.env";
  environmentTemplate = pkgs.writeText "tuwunel.env.template" /* ini */ ''
    TUWUNEL_SERVER_NAME=$domain
    TUWUNEL_WELL_KNOWN__CLIENT=https://$domain
    TUWUNEL_WELL_KNOWN__SERVER=$domain:443
    TUWUNEL_REGISTRATION_TOKEN=$registration_token
  '';

  traefikFile = "${config.services.traefik.dataDir}/dynamic/tuwunel.yaml";
  traefikTemplate = pkgs.writeText "traefik-tuwunel.yaml.template" /* yaml */ ''
    http:
      routers:
        tuwunel:
          rule: "Host(`$domain`)"
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

  fetchSecrets = pkgs.writeShellApplication {
    name = "tuwunel-fetch-secrets";

    runtimeInputs = with pkgs; [
      coreutils
      pythonScriptEnv
    ];

    text = /* sh */ ''
      ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "openbao/render-template.py"} \
        --address ${addressArgument} \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString environmentTemplate)} \
        --output-file ${lib.escapeShellArg environmentFile} \
        --secret domain shared/domain matrix \
        --secret registration_token ${lib.escapeShellArg "server/${hostname}"} tuwunel_registration_token

      ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "openbao/render-template.py"} \
        --address ${addressArgument} \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString traefikTemplate)} \
        --output-file ${lib.escapeShellArg "${runtimeDirectory}/traefik.yaml"} \
        --secret domain shared/domain matrix

      install -d -m 0755 ${lib.escapeShellArg "${config.services.traefik.dataDir}/dynamic"}
      install -m 0400 -o traefik ${lib.escapeShellArg "${runtimeDirectory}/traefik.yaml"} ${lib.escapeShellArg "${traefikFile}.tmp"}
      mv -T ${lib.escapeShellArg "${traefikFile}.tmp"} ${lib.escapeShellArg traefikFile}
    '';
  };
in
lib.mkIf config.services.matrix-tuwunel.enable {
  services.matrix-tuwunel.environmentFile = environmentFile;

  systemd.services.tuwunel-secrets = {
    description = "Load Tuwunel secrets from OpenBao";

    wantedBy = [ "multi-user.target" ];
    requires = [ "openbao-client-login.service" ];
    after = [ "openbao-client-login.service" ];
    before = [ "tuwunel.service" ];
    unitConfig.StartLimitIntervalSec = 0;

    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "2min";
      ExecStart = lib.getExe fetchSecrets;
      ExecStartPost = "${lib.getExe' pkgs.systemd "systemctl"} --no-block start tuwunel.service";
      RemainAfterExit = true;
      RuntimeDirectory = "tuwunel-secrets";
      RuntimeDirectoryMode = "0700";
      RuntimeDirectoryPreserve = "restart";
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };

  systemd.services.tuwunel = {
    partOf = [ "tuwunel-secrets.service" ];
    requires = [ "tuwunel-secrets.service" ];
    after = [ "tuwunel-secrets.service" ];
  };
}
