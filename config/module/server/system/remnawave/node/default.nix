{
  config,
  lib,
  pkgs,
  ports,
  remnawaveContainerCommon,
  ...
}:
let
  nodeEnvFile = "/run/remnawave-node-secrets/node.env";

  composeFile = pkgs.writeText "remnawave-node-compose.json" (
    builtins.toJSON {
      services = {
        remnanode = (removeAttrs remnawaveContainerCommon [ "networks" ]) // {
          image = "remnawave/node:latest";
          container_name = "remnanode";
          hostname = "remnanode";
          network_mode = "host";
          cap_add = [ "NET_ADMIN" ];
          env_file = [ nodeEnvFile ];
        };
      };
    }
  );
in
{
  imports = [
    ./firewall.nix
    ./hopping.nix
    ./masking
    ./openbao.nix
  ];

  options.services.remnawave-node = {
    enable = lib.mkEnableOption "Remnawave node container";

    hopping.enable = lib.mkEnableOption "Remnawave node port hopping";

    hopping.availableNodeCount = lib.mkOption {
      description = "Number of consecutive TCP ports to open from the start of the Remnawave port hopping range.";
      type = lib.types.ints.between 1 ports.remnawave.node.hopping.count;
      default = 1;
    };
  };

  config.systemd.services = lib.mkIf config.services.remnawave-node.enable {
    remnawave-node = {
      description = "Remnawave node container";

      partOf = [ "remnawave-node-secrets.service" ];
      wantedBy = [ "multi-user.target" ];
      requires = [
        "docker.service"
        "nftables.service"
        "remnawave-node-secrets.service"
        "traefik.service"
      ];
      after = [
        "docker.service"
        "network-online.target"
        "nftables.service"
        "remnawave-node-secrets.service"
        "traefik.service"
      ];
      wants = [
        "network-online.target"
        "remnawave-node-mask.service"
      ];
      restartTriggers = [ composeFile ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${lib.getExe pkgs.docker-compose} --project-name remnawave-node -f ${composeFile} up --detach --remove-orphans --pull always";
        ExecStop = "${lib.getExe pkgs.docker-compose} --project-name remnawave-node -f ${composeFile} down";
        Restart = "on-failure";
        RestartSec = "30s";
        TimeoutStartSec = 600;
        TimeoutStopSec = 60;
      };
    };
  };
}
