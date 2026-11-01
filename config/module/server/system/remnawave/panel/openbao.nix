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
  addressArgument = import ../../../openbao-address-argument.nix {
    inherit
      config
      lib
      pkgs
      ports
      ;
  };

  runtimeDirectory = "/run/remnawave-panel-secrets";

  panelTemplate = pkgs.writeText "remnawave-panel.env.template" /* ini */ ''
    APP_PORT=${toString ports.remnawave.panel.port}
    METRICS_PORT=${toString ports.remnawave.panel.metrics}
    METRICS_USER=admin
    METRICS_PASS=admin
    API_INSTANCES=1

    DATABASE_URL=postgresql://postgres:postgres@remnawave-db:${toString ports.remnawave.database}/postgres
    REDIS_SOCKET=/var/run/valkey/valkey.sock

    APP_SECRET=$app_secret

    FRONT_END_DOMAIN=*
    SUB_PUBLIC_DOMAIN=$subscription_domain

    IS_TELEGRAM_NOTIFICATIONS_ENABLED=false
    WEBHOOK_ENABLED=false

    POSTGRES_USER=postgres
    POSTGRES_PASSWORD=postgres
    POSTGRES_DB=postgres
  '';

  subscriptionTemplate = pkgs.writeText "remnawave-subscription.env.template" /* ini */ ''
    APP_PORT=${toString ports.remnawave.panel.subscription}
    REMNAWAVE_PANEL_URL=http://remnawave:${toString ports.remnawave.panel.port}
    REMNAWAVE_API_TOKEN=$api_token

    TRUST_PROXY=1
    CUSTOM_SUB_PREFIX=
    MARZBAN_LEGACY_LINK_ENABLED=false
  '';

  apiTokenTemplate = pkgs.writeText "remnawave-api-token.template" "$api_token";

  traefikFile = "${config.services.traefik.dataDir}/dynamic/remnawave-subscription.yaml";
  traefikTemplate = pkgs.writeText "traefik-remnawave-subscription.yaml.template" /* yaml */ ''
    http:
      routers:
        remnawave-subscription:
          rule: "Host(`$domain`)"
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

  fetchSecrets = pkgs.writeShellApplication {
    name = "remnawave-panel-fetch-secrets";

    runtimeInputs = with pkgs; [
      coreutils
      pythonScriptEnv
    ];

    text = /* sh */ ''
      ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "openbao/render-template.py"} \
        --address ${addressArgument} \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString panelTemplate)} \
        --output-file ${lib.escapeShellArg "${runtimeDirectory}/panel.env"} \
        --secret app_secret ${lib.escapeShellArg "server/${hostname}"} remnawave_app_secret \
        --secret subscription_domain shared/domain remnawave_subscription

      ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "openbao/render-template.py"} \
        --address ${addressArgument} \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString subscriptionTemplate)} \
        --output-file ${lib.escapeShellArg "${runtimeDirectory}/subscription.env"} \
        --secret api_token ${lib.escapeShellArg "server/${hostname}"} remnawave_api_token

      ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "openbao/render-template.py"} \
        --address ${addressArgument} \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString apiTokenTemplate)} \
        --output-file ${lib.escapeShellArg "${runtimeDirectory}/api-token"} \
        --secret api_token ${lib.escapeShellArg "server/${hostname}"} remnawave_api_token

      ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "openbao/render-template.py"} \
        --address ${addressArgument} \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString traefikTemplate)} \
        --output-file ${lib.escapeShellArg "${runtimeDirectory}/traefik.yaml"} \
        --secret domain shared/domain remnawave_subscription

      install -d -m 0755 ${lib.escapeShellArg "${config.services.traefik.dataDir}/dynamic"}
      install -m 0400 -o traefik ${lib.escapeShellArg "${runtimeDirectory}/traefik.yaml"} ${lib.escapeShellArg "${traefikFile}.tmp"}
      mv -T ${lib.escapeShellArg "${traefikFile}.tmp"} ${lib.escapeShellArg traefikFile}
    '';
  };
in
lib.mkIf config.services.remnawave-panel.enable {
  systemd.services.remnawave-panel-secrets = {
    description = "Load Remnawave panel secrets from OpenBao";

    wantedBy = [ "multi-user.target" ];
    requires = [ "openbao-client-login.service" ];
    after = [ "openbao-client-login.service" ];
    before = [ "remnawave-panel.service" ];
    unitConfig.StartLimitIntervalSec = 0;

    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "2min";
      ExecStart = lib.getExe fetchSecrets;
      ExecStartPost = "${lib.getExe' pkgs.systemd "systemctl"} --no-block start remnawave-panel.service";
      RemainAfterExit = true;
      RuntimeDirectory = "remnawave-panel-secrets";
      RuntimeDirectoryMode = "0700";
      RuntimeDirectoryPreserve = "restart";
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };
}
