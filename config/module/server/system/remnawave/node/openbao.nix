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

  runtimeDirectory = "/run/remnawave-node-secrets";

  environmentTemplate = pkgs.writeText "remnawave-node.env.template" /* ini */ ''
    NODE_PORT=${toString ports.remnawave.node.port}
    SECRET_KEY=$secret_key
  '';

  firewallTemplate = pkgs.writeText "remnawave-node-firewall.nft.template" /* nftables */ ''
    flush set inet nixos-fw remnawave_panel_ipv4
    add element inet nixos-fw remnawave_panel_ipv4 { $panel_ip }
  '';

  traefikFile = "${config.services.traefik.dataDir}/dynamic/remnawave-node-mask.yaml";
  traefikTemplate = pkgs.writeText "traefik-remnawave-node-mask.yaml.template" /* yaml */ ''
    http:
      routers:
        remnawave-node-mask:
          rule: "Host(`$domain`)"
          entryPoints:
            - websecure
          service: remnawave-node-mask
          tls:
            certResolver: letsencrypt

      services:
        remnawave-node-mask:
          loadBalancer:
            servers:
              - url: "http://127.0.0.1:${toString ports.remnawave.mask.backend}"
  '';

  fetchSecrets = pkgs.writeShellApplication {
    name = "remnawave-node-fetch-secrets";

    runtimeInputs = with pkgs; [
      coreutils
      nftables
      pythonScriptEnv
    ];

    text = /* sh */ ''
      ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "openbao/render-template.py"} \
        --address ${addressArgument} \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString environmentTemplate)} \
        --output-file ${lib.escapeShellArg "${runtimeDirectory}/node.env"} \
        --secret secret_key shared/remnawave secret_key

      ${lib.optionalString (!config.services.remnawave-panel.enable) /* sh */ ''
        ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "openbao/render-template.py"} \
          --address ${addressArgument} \
          --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
          --mount config \
          --template-file ${lib.escapeShellArg (toString firewallTemplate)} \
          --output-file ${lib.escapeShellArg "${runtimeDirectory}/firewall.nft"} \
          --secret panel_ip shared/remnawave panel_ip

        ${lib.getExe pkgs.nftables} --file ${lib.escapeShellArg "${runtimeDirectory}/firewall.nft"}
      ''}

      ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "openbao/render-template.py"} \
        --address ${addressArgument} \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString traefikTemplate)} \
        --output-file ${lib.escapeShellArg "${runtimeDirectory}/traefik.yaml"} \
        --secret domain shared/remnawave ${lib.escapeShellArg "remnawave_node_domain_${hostname}"}

      install -d -m 0755 ${lib.escapeShellArg "${config.services.traefik.dataDir}/dynamic"}
      install -m 0400 -o traefik ${lib.escapeShellArg "${runtimeDirectory}/traefik.yaml"} ${lib.escapeShellArg "${traefikFile}.tmp"}
      mv -T ${lib.escapeShellArg "${traefikFile}.tmp"} ${lib.escapeShellArg traefikFile}
    '';
  };
in
lib.mkIf config.services.remnawave-node.enable {
  systemd.services.remnawave-node-secrets = {
    description = "Load Remnawave node secrets from OpenBao";

    wantedBy = [ "multi-user.target" ];
    requires = [
      "openbao-client-login.service"
      "nftables.service"
    ];
    after = [
      "openbao-client-login.service"
      "nftables.service"
    ];
    before = [ "remnawave-node.service" ];
    unitConfig.StartLimitIntervalSec = 0;

    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "2min";
      ExecStart = lib.getExe fetchSecrets;
      ExecStartPost = "${lib.getExe' pkgs.systemd "systemctl"} --no-block start remnawave-node.service";
      RemainAfterExit = true;
      RuntimeDirectory = "remnawave-node-secrets";
      RuntimeDirectoryMode = "0700";
      RuntimeDirectoryPreserve = "restart";
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };
}
