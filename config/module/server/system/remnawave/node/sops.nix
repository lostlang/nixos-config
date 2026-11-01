{
  config,
  lib,
  ports,
  ...
}:
{
  sops = lib.mkIf config.services.remnawave-node.enable {
    secrets = {
      "remnawave.node.panel-ip" = { };
      "remnawave.node.secret-key" = { };
    };

    templates."remnawave-node-firewall.nft" = {
      mode = "0400";
      restartUnits = [ "nftables.service" ];
      content = ''
        ip saddr ${
          config.sops.placeholder."remnawave.node.panel-ip"
        } tcp dport ${toString ports.remnawave.node.port} accept
      '';
    };

    templates."remnawave-node.env" = {
      mode = "0400";
      restartUnits = [ "remnawave-node.service" ];
      content = /* ini */ ''
        NODE_PORT=${toString ports.remnawave.node.port}
        SECRET_KEY=${config.sops.placeholder."remnawave.node.secret-key"}
      '';
    };
  };
}
