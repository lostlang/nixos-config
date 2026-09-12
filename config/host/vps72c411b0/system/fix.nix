{
  config,
  lib,
  hostname,
  ...
}:
{
  security.sudo.wheelNeedsPassword = lib.mkForce false;

  # The provider assigns a static public /32 with an on-link gateway that lives
  # outside the subnet; there is no DHCP server (dhcpcd only ever got a
  # 169.254.x link-local fallback). Configure it explicitly via
  # systemd-networkd so GatewayOnLink makes the off-subnet default route valid.
  #
  # The public IP is a sops secret keyed by hostname (vps.${hostname}.ip),
  # declared in module/core/system/networking/vps.nix. The .network unit is
  # rendered from a sops template into /run/systemd/network (tmpfs) at
  # activation, so the store only ever holds a placeholder token.
  networking = {
    useDHCP = lib.mkForce false;
    interfaces = lib.mkForce { };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  systemd.network.enable = true;

  sops.templates."10-ens3.network" = {
    path = "/run/systemd/network/10-ens3.network";
    mode = "0644";
    content = ''
      [Match]
      Name=ens3

      [Network]
      Address=${config.sops.placeholder."vps.${hostname}.ip"}

      [Route]
      Gateway=172.16.0.1
      GatewayOnLink=yes

      [Link]
      RequiredForOnline=routable
    '';
  };
}
