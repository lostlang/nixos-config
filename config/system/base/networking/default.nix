{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./cloudflare
    ./zerotierone
  ];

  networking = {
    firewall = {
      enable = true;
    };
  };

  systemd.services = {
    firewall = {
      enable = lib.mkForce true;

      path = with pkgs; [
        gawk
        iproute2
      ];
    };

    local-fw = {
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
        iproute2
        iptables
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.writeShellScript "custom-fw" ''
          set -e

          while true; do
            LOCAL_IP=$(ip route get 1 | awk '{print $7; exit}')
            if [[ -z "$LOCAL_IP" || "$LOCAL_IP" == 127.* ]]; then
              echo "⚠️  Local IP is not ready yet: $LOCAL_IP"
              sleep 1
            else
              break
            fi
          done

          SUBNET=$(ip -o -f inet addr show | grep "$LOCAL_IP" | awk '{print $4}')

          if ! iptables -C nixos-fw -s "$SUBNET" -j nixos-fw-accept 2>/dev/null; then
            REFUSE_LINE=$(iptables -nL nixos-fw --line-numbers | awk '$2=="nixos-fw-log-refuse"{print $1; exit}')
            if [[ -n "$REFUSE_LINE" ]]; then
              iptables -I nixos-fw "$REFUSE_LINE" -s "$SUBNET" -j nixos-fw-accept
            else
              iptables -A nixos-fw -s "$SUBNET" -j nixos-fw-accept
            fi
          fi

          echo "✅ Adding firewall rule for subnet: $SUBNET"
        ''}";
      };
    };
  };
}
