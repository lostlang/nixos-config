{
  config,
  lib,
  pkgs,
  ports,
  remnawave,
  ...
}:
let
  localPanel = config.services.remnawave-panel.enable;
in
{
  networking = lib.mkIf config.services.remnawave-node.enable {
    nftables.tables."nixos-fw".content = lib.mkIf (!localPanel) (
      lib.mkBefore /* nftables */ ''
        set remnawave_panel_ipv4 {
          type ipv4_addr
        }
      ''
    );
    firewall.extraInputRules =
      if localPanel then
        /* nftables */ ''
          ip saddr ${remnawave.panel.address} tcp dport ${toString ports.remnawave.node.port} accept
        ''
      else
        /* nftables */ ''
          ip saddr @remnawave_panel_ipv4 tcp dport ${toString ports.remnawave.node.port} accept
        '';
  };

  systemd.services.nftables = lib.mkIf (config.services.remnawave-node.enable && !localPanel) {
    serviceConfig = {
      ExecStartPost = lib.mkAfter [
        "-${lib.getExe pkgs.nftables} --file /run/remnawave-node-secrets/firewall.nft"
      ];
      ExecReload = lib.mkAfter [
        "-${lib.getExe pkgs.nftables} --file /run/remnawave-node-secrets/firewall.nft"
      ];
    };
  };
}
