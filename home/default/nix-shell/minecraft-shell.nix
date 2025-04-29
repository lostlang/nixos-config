{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  name = "minecraft-server";

  buildInputs = with pkgs; [ temurin-bin-21 ];

  shellHook = ''
    MARKER_FILE="/tmp/minecraft_iptables_rule_set"

    LOCAL_IP=$(ip route get 1 | awk '{print $7; exit}')
    SUBNET=$(ip -o -f inet addr show | grep "$LOCAL_IP" | awk '{print $4}')

    if [ ! -f "$MARKER_FILE" ]; then
      sudo iptables -I INPUT -p tcp --dport 25565 -s "$SUBNET" -j ACCEPT
      echo "$SUBNET" > "$MARKER_FILE"
    fi

    cleanup() {
      if [ -f "$MARKER_FILE" ]; then
        SUBNET=$(cat "$MARKER_FILE")
        sudo iptables -D INPUT -p tcp --dport 25565 -s "$SUBNET" -j ACCEPT
        rm -f "$MARKER_FILE"
      fi
    }

    trap cleanup EXIT
  '';
}
