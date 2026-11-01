{
  config,
  lib,
  pkgs,
  ports,
  remnawave,
  remnawaveContainerCommon,
  ...
}:
let
  panelEnvFile = "/run/remnawave-panel-secrets/panel.env";
  subscriptionEnvFile = "/run/remnawave-panel-secrets/subscription.env";

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
            "127.0.0.1:${toString ports.remnawave.panel.port}:${toString ports.remnawave.panel.port}"
            "127.0.0.1:${toString ports.remnawave.panel.metrics}:${toString ports.remnawave.panel.metrics}"
          ];
          healthcheck = {
            test = [
              "CMD-SHELL"
              "curl -f http://localhost:${toString ports.remnawave.panel.metrics}/health"
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
          command = [
            "postgres"
            "-p"
            (toString ports.remnawave.database)
          ];
          healthcheck = {
            test = [
              "CMD-SHELL"
              "pg_isready -p ${toString ports.remnawave.database} -U $\${POSTGRES_USER} -d $\${POSTGRES_DB}"
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
            "127.0.0.1:${toString ports.remnawave.panel.subscription}:${toString ports.remnawave.panel.subscription}"
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
    ./bootstrap.nix
    ./openbao.nix
  ];

  options.services.remnawave-panel.enable = lib.mkEnableOption "Remnawave panel containers";

  config.services.traefik.enable = lib.mkIf config.services.remnawave-panel.enable true;

  config.systemd.services.remnawave-panel = lib.mkIf config.services.remnawave-panel.enable {
    description = "Remnawave panel containers";

    partOf = [ "remnawave-panel-secrets.service" ];
    wantedBy = [ "multi-user.target" ];
    requires = [
      "docker.service"
      "remnawave-panel-secrets.service"
    ];
    after = [
      "docker.service"
      "network-online.target"
      "remnawave-panel-secrets.service"
    ];
    wants = [ "network-online.target" ];
    restartTriggers = [ composeFile ];

    serviceConfig = {
      RemainAfterExit = true;
      ExecStart = "${lib.getExe pkgs.docker-compose} --project-name remnawave-panel -f ${composeFile} up --detach --remove-orphans --wait --pull always";
      ExecStop = "${lib.getExe pkgs.docker-compose} --project-name remnawave-panel -f ${composeFile} down";
      Restart = "on-failure";
      RestartSec = "30s";
      TimeoutStartSec = 600;
      TimeoutStopSec = 60;
    };
  };
}
