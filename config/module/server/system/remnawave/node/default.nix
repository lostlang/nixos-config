{
  config,
  lib,
  pkgs,
  ports,
  remnawaveContainerCommon,
  ...
}:
let
  nodeEnvFile = config.sops.templates."remnawave-node.env".path;

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
    ./sops.nix
  ];

  options.services.remnawave-node = {
    enable = lib.mkEnableOption "the Remnawave node container";

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

      wantedBy = [ "multi-user.target" ];
      requires = [
        "docker.service"
        "nftables.service"
        "traefik.service"
      ];
      after = [
        "docker.service"
        "network-online.target"
        "nftables.service"
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
        TimeoutStartSec = 600;
        TimeoutStopSec = 60;
      };
    };
  };
}
