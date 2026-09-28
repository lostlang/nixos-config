{
  config,
  lib,
  ports,
  ...
}:
let
  cfg = config.services.remnawave-node;
in
{
  networking.firewall.allowedTCPPorts = lib.mkIf (cfg.enable && cfg.hopping.enable) (
    lib.range ports.remnawave.node.hopping.start (
      ports.remnawave.node.hopping.start + cfg.hopping.availableNodeCount - 1
    )
  );
}
