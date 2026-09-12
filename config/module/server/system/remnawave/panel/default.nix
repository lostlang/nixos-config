{
  config,
  lib,
  pkgs,
  remnawave,
  remnawaveContainerCommon,
  ...
}:
let
  cfg = config.services.remnawave-panel;
  panelEnvFile = config.sops.templates."remnawave-panel.env".path;
  subscriptionEnvFile = config.sops.templates."remnawave-subscription.env".path;

  composeFile = pkgs.writeText "remnawave-panel-compose.json" (
    builtins.toJSON {
      services = {
        remnawave = remnawaveContainerCommon // {
          image = "remnawave/backend:3";
          container_name = "remnawave";
          hostname = "remnawave";
          networks.remnawave-network.ipv4_address = remnawave.panel.address;
          env_file = [ panelEnvFile ];
          volumes = [ "valkey-socket:/var/run/valkey" ];
          ports = [
            "127.0.0.1:${toString remnawave.panel.port}:${toString remnawave.panel.port}"
            "127.0.0.1:${toString remnawave.panel.metrics.port}:${toString remnawave.panel.metrics.port}"
          ];
          healthcheck = {
            test = [
              "CMD-SHELL"
              "curl -f http://localhost:${toString remnawave.panel.metrics.port}/health"
            ];
            interval = "30s";
            timeout = "5s";
            retries = 3;
            start_period = "30s";
          };
          depends_on = {
            remnawave-db.condition = "service_healthy";
            remnawave-redis.condition = "service_healthy";
          };
        };

        remnawave-db = remnawaveContainerCommon // {
          image = "postgres:18";
          container_name = "remnawave-db";
          hostname = "remnawave-db";
          shm_size = "512mb";
          env_file = [ panelEnvFile ];
          volumes = [ "remnawave-db-data:/var/lib/postgresql" ];
          healthcheck = {
            test = [
              "CMD-SHELL"
              "pg_isready -U $\${POSTGRES_USER} -d $\${POSTGRES_DB}"
            ];
            interval = "3s";
            timeout = "10s";
            retries = 3;
          };
        };

        remnawave-redis = remnawaveContainerCommon // {
          image = "valkey/valkey:9-alpine";
          container_name = "remnawave-redis";
          hostname = "remnawave-redis";
          volumes = [ "valkey-socket:/var/run/valkey" ];
          command = [
            "valkey-server"
            "--save"
            ""
            "--appendonly"
            "no"
            "--maxmemory"
            "256mb"
            "--maxmemory-policy"
            "noeviction"
            "--loglevel"
            "warning"
            "--unixsocket"
            "/var/run/valkey/valkey.sock"
            "--unixsocketperm"
            "777"
            "--port"
            "0"
          ];
          healthcheck = {
            test = [
              "CMD"
              "valkey-cli"
              "-s"
              "/var/run/valkey/valkey.sock"
              "ping"
            ];
            interval = "3s";
            timeout = "3s";
            retries = 3;
          };
        };

        remnawave-subscription-page = remnawaveContainerCommon // {
          image = "remnawave/subscription-page:latest";
          container_name = "remnawave-subscription-page";
          hostname = "remnawave-subscription-page";
          env_file = [ subscriptionEnvFile ];
          ports = [
            "127.0.0.1:${toString remnawave.panel.subscription.port}:${toString remnawave.panel.subscription.port}"
          ];
          depends_on.remnawave.condition = "service_healthy";
        };
      };

      networks.remnawave-network = {
        name = "remnawave-network";
        driver = "bridge";
        ipam.config = [
          {
            subnet = remnawave.network.subnet;
            ip_range = remnawave.network.pool;
            gateway = remnawave.network.gateway;
          }
        ];
      };

      volumes = {
        remnawave-db-data = {
          name = "remnawave-db-data";
          driver = "local";
        };
        valkey-socket = {
          name = "valkey-socket";
          driver = "local";
        };
      };
    }
  );
in
{
  imports = [
    ./bootstrap

    ./options.nix
    ./sops.nix
    ./traefik.nix
  ];

  systemd.services.remnawave-panel = lib.mkIf cfg.enable {
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [
      "docker.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    restartTriggers = [ composeFile ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${lib.getExe pkgs.docker-compose} --project-name remnawave-panel -f ${composeFile} up --detach --remove-orphans --wait --pull always";
      ExecStop = "${lib.getExe pkgs.docker-compose} --project-name remnawave-panel -f ${composeFile} down";
      TimeoutStartSec = 600;
      TimeoutStopSec = 60;
    };
  };
}
