{
  config,
  lib,
  ports,
  ...
}:
{
  sops = lib.mkIf config.services.remnawave-panel.enable {
    secrets = {
      "domain.remnawave.subscription" = { };
      "remnawave.api-token" = { };
      "remnawave.panel.app-secret" = { };
    };

    templates."remnawave-panel.env" = {
      mode = "0400";
      restartUnits = [ "remnawave-panel.service" ];
      content = ''
        APP_PORT=${toString ports.remnawave.panel.port}
        METRICS_PORT=${toString ports.remnawave.panel.metrics}
        METRICS_USER=admin
        METRICS_PASS=admin
        API_INSTANCES=1

        DATABASE_URL=postgresql://postgres:postgres@remnawave-db:${toString ports.remnawave.database}/postgres
        REDIS_SOCKET=/var/run/valkey/valkey.sock

        APP_SECRET=${config.sops.placeholder."remnawave.panel.app-secret"}

        FRONT_END_DOMAIN=*
        SUB_PUBLIC_DOMAIN=${config.sops.placeholder."domain.remnawave.subscription"}

        IS_TELEGRAM_NOTIFICATIONS_ENABLED=false
        WEBHOOK_ENABLED=false

        POSTGRES_USER=postgres
        POSTGRES_PASSWORD=postgres
        POSTGRES_DB=postgres
      '';
    };

    templates."remnawave-subscription.env" = {
      mode = "0400";
      restartUnits = [ "remnawave-panel.service" ];
      content = ''
        APP_PORT=${toString ports.remnawave.panel.subscription}
        REMNAWAVE_PANEL_URL=http://remnawave:${toString ports.remnawave.panel.port}
        REMNAWAVE_API_TOKEN=${config.sops.placeholder."remnawave.api-token"}

        TRUST_PROXY=1
        CUSTOM_SUB_PREFIX=
        MARZBAN_LEGACY_LINK_ENABLED=false
      '';
    };
  };
}
