{
  config,
  lib,
  pkgs,
  ...
}:
let
  enable = config.myConfig.zerotierone.enable;
  interfaces = config.myConfig.zerotierone.interfaces;
in
{
  imports = [
    ./options.nix
    ./sops.nix
  ];

  networking = lib.mkIf enable {
    firewall = {
      allowedUDPPorts = [ 9993 ];
    };
  };

  services.zerotierone = lib.mkIf enable {
    enable = true;
  };

  systemd.services = lib.mkIf (enable && interfaces != [ ]) (
    builtins.listToAttrs (
      map (name: {
        name = "zerotier-open-ports-${name}";
        value = {
          wantedBy = [ "multi-user.target" ];
          wants = [
            "network-online.target"
            "zerotierone.service"
            "firewall.service"
          ];
          after = [
            "network-online.target"
            "zerotierone.service"
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
            EnvironmentFile = config.sops.templates."zerotier/${name}.env".path;
            ExecStart = "${pkgs.writeShellScript "zerotier-open-ports-${name}" ''
              set -euo pipefail

              if [[ -z "''${ZEROTIER_INTERFACE_ID:-}" ]]; then
                echo "ZEROTIER_INTERFACE_ID is not set"
                exit 1
              fi

              iface=""
              if ip link show "$ZEROTIER_INTERFACE_ID" >/dev/null 2>&1; then
                iface="$ZEROTIER_INTERFACE_ID"
              else
                echo "Waiting for Zerotier interface $ZEROTIER_INTERFACE_ID to be available..."
                exit 1
              fi

              open_ports() {
                local proto="$1"
                local ports="$2"
                local port

                for port in $ports; do
                  if [[ -z "$port" ]]; then
                    continue
                  fi

                  if ! iptables -C nixos-fw -i "$iface" -p "$proto" --dport "$port" -j nixos-fw-accept 2>/dev/null; then
                    REFUSE_LINE=$(iptables -nL nixos-fw --line-numbers | awk '$2=="nixos-fw-log-refuse"{print $1; exit}')
                    if [[ -n "$REFUSE_LINE" ]]; then
                      iptables -I nixos-fw "$REFUSE_LINE" -i "$iface" -p "$proto" --dport "$port" -j nixos-fw-accept
                    else
                      iptables -A nixos-fw -i "$iface" -p "$proto" --dport "$port" -j nixos-fw-accept
                    fi
                  fi
                done
              }

              if [[ -n "''${ZEROTIER_OPEN_UDP_PORTS:-}" ]]; then
                open_ports udp "$ZEROTIER_OPEN_UDP_PORTS"
              fi
              if [[ -n "''${ZEROTIER_OPEN_TCP_PORTS:-}" ]]; then
                open_ports tcp "$ZEROTIER_OPEN_TCP_PORTS"
              fi
            ''}";
          };
        };
      }) interfaces
    )
  );
}
