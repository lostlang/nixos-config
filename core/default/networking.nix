{
  networking.firewall = {
    enable = true;

    extraCommands = ''
      LOCAL_IP=$(ip route get 1 | awk '{print $7; exit}')
      SUBNET=$(ip -o -f inet addr show | grep "$LOCAL_IP" | awk '{print $4}')

      iptables -A INPUT -p tcp -s $SUBNET -j ACCEPT
      iptables -A INPUT -p udp -s $SUBNET -j ACCEPT

      iptables -A INPUT -p tcp -j DROP
      iptables -A INPUT -p udp -j DROP
    '';
  };
}
