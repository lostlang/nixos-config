{
  config,
  lib,
  pkgs,
  ports,
  pythonScriptEnv,
  ...
}:
let
  panelCfg = config.services.remnawave-panel;
  nodes = panelCfg.nodes.basic ++ panelCfg.nodes.hopping;
  nodeDomainsFile = config.sops.templates."remnawave-node-domains.json".path;
  bootstrap = pkgs.writeShellApplication {
    name = "remnawave-node-bootstrap";
    runtimeInputs = [ pythonScriptEnv ];
    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} -u ${pythonScriptEnv}/scripts/remnawave-bootstrap.py \
        --api-port ${toString ports.remnawave.panel.port} \
        --mask-port ${toString ports.remnawave.mask.entryPoint} \
        --nodes-file ${lib.escapeShellArg nodeDomainsFile} \
        --api-token-file ${lib.escapeShellArg config.sops.secrets."remnawave.api-token".path} \
        ${lib.optionalString config.services.adguardhome.enable "--adguard-domain-file ${lib.escapeShellArg config.sops.secrets."domain.adguardhome".path}"} \
        "$@"
    '';
  };
in
{
  imports = [
    ./sops.nix
  ];

  options.services.remnawave-panel = {
    bootstrap.enable = lib.mkEnableOption "automatic Remnawave node bootstrap";

    nodes = {
      basic = lib.mkOption {
        description = "Node names to register in Remnawave panel without port hopping.";
        type = lib.types.listOf lib.types.str;
        default = [ ];
        apply = lib.unique;
      };

      hopping = lib.mkOption {
        description = "Node names to register in Remnawave panel with port hopping.";
        type = lib.types.listOf lib.types.str;
        default = [ ];
        apply = lib.unique;
      };
    };
  };

  config = lib.mkIf (panelCfg.enable && panelCfg.bootstrap.enable && nodes != [ ]) {
    environment.systemPackages = [ bootstrap ];

    systemd.services.remnawave-node-bootstrap = {
      description = "Bootstrap Remnawave nodes in panel";

      wantedBy = [ "multi-user.target" ];
      requires = [ "remnawave-panel.service" ];
      after = [
        "network-online.target"
        "remnawave-panel.service"
      ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe bootstrap;
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = 10;
        TimeoutStartSec = 180;
      };
    };
  };
}
