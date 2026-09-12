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
  networking.firewall.allowedTCPPorts = lib.mkIf (cfg.enable && cfg.hopping.enable) (
    lib.range remnawave.node.hopping.port (
      remnawave.node.hopping.port + cfg.hopping.availableNodeCount - 1
    )
  );
}
