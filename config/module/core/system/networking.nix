{
  lib,
  pkgs,
  ...
}:
{
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
  };
}
