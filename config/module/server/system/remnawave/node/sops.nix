{
  config,
  lib,
  remnawave,
  ...
}:
let
  cfg = config.services.remnawave-node;
in
{
  sops = lib.mkIf cfg.enable {
    secrets = {
      "remnawave.node.panel-ip" = { };
      "remnawave.node.secret-key" = { };
    };

    templates."remnawave-node-firewall.env" = {
      mode = "0400";
      restartUnits = [ "remnawave-node-firewall.service" ];
      content = ''
        PANEL_IP=${config.sops.placeholder."remnawave.node.panel-ip"}
      '';
    };

    templates."remnawave-node.env" = {
      mode = "0400";
      restartUnits = [ "remnawave-node.service" ];
      content = ''
        NODE_PORT=${toString remnawave.node.port}
        SECRET_KEY=${config.sops.placeholder."remnawave.node.secret-key"}
      '';
    };
  };
}
