{
  config,
  lib,
  pkgs,
  remnawave,
  ...
}:
let
  cfg = config.services.remnawave-node;
  firewallEnvFile = config.sops.templates."remnawave-node-firewall.env".path;

  firewallScript = pkgs.writeShellScript "remnawave-node-firewall" ''
    set -euo pipefail

    if iptables -C nixos-fw -s "$PANEL_IP" -p tcp --dport ${toString remnawave.node.port} -j nixos-fw-accept 2>/dev/null; then
      exit 0
    fi

    refuseLine=$(iptables -nL nixos-fw --line-numbers | awk '$2 == "nixos-fw-log-refuse" { print $1; exit }')
    if [[ -n "$refuseLine" ]]; then
      iptables -I nixos-fw "$refuseLine" -s "$PANEL_IP" -p tcp --dport ${toString remnawave.node.port} -j nixos-fw-accept
    fi
  '';
in
{
  systemd.services.remnawave-node-firewall = lib.mkIf cfg.enable {
    wantedBy = [ "multi-user.target" ];
    wants = [
      "network-online.target"
      "firewall.service"
    ];
    after = [
      "network-online.target"
      "firewall.service"
    ];
    path = with pkgs; [
      gawk
      iptables
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      EnvironmentFile = firewallEnvFile;
      ExecStart = firewallScript;
    };
  };
}
