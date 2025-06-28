{ pkgs, ... }:
{
  networking.firewall = {
    enable = true;

    # extraCommands = ''
    #   LOCAL_IP=$(ip route get 1 | awk '{print $7; exit}')
    #   SUBNET=$(ip -o -f inet addr show | grep "$LOCAL_IP" | awk '{print $4}')
    #
    #   iptables -A INPUT -s $SUBNET -j ACCEPT
    #
    #   iptables -A nixos-fw -s "$SUBNET" -j nixos-fw-accept
    # '';
  };

  systemd.services.firewall = {
    enable = true;
    path = with pkgs; [
      gawk
      iproute2
    ];
  };

  systemd.services.local-fw = {
    after = [
      "network-online.target"
      "firewall.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      iproute2
      gawk
      iptables
    ];

    serviceConfig.ExecStart = "${pkgs.writeShellScript "custom-fw" ''
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

      iptables -A nixos-fw -s "$SUBNET" -j nixos-fw-accept

      iptables -L nixos-fw --line-numbers | grep nixos-fw-log-refuse | awk '{print $1}' | sort -rn | while read -r line; do iptables -D nixos-fw "$line"; done
      iptables -A nixos-fw -j nixos-fw-log-refuse 

      echo "✅ Adding firewall rule for subnet: $SUBNET"
    ''}";
  };
}
