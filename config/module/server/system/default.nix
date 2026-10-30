{
  lib,
  ...
}:
{
  imports = [
    ./adguardhome
    ./matrix
    ./openbao
    ./remnawave
    ./vaultwarden

    ./weekly-reboot.nix
    ./traefik.nix
  ];

  programs.openbao-client.enable = lib.mkDefault true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
