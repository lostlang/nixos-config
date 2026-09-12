{
  config,
  lib,
  pkgs,
  remnawaveContainerCommon,
  remnawaveNodeMaskContainer,
  ...
}:
let
  cfg = config.services.remnawave-node;
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

        remnawave-node-mask = remnawaveNodeMaskContainer;
      };
    }
  );
in
{
  imports = [
    ./firewall.nix
    ./hopping.nix
    ./masking
    ./options.nix
    ./sops.nix
  ];

  systemd.services = lib.mkIf cfg.enable {
    remnawave-node = {
      wantedBy = [ "multi-user.target" ];
      requires = [
        "docker.service"
        "remnawave-node-firewall.service"
        "traefik.service"
      ];
      after = [
        "docker.service"
        "network-online.target"
        "remnawave-node-firewall.service"
        "traefik.service"
      ];
      wants = [ "network-online.target" ];
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
