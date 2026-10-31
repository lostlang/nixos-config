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

    ./docker.nix
    ./nix.nix
    ./traefik.nix
    ./weekly-reboot.nix
  ];

  programs.openbao-client.enable = lib.mkDefault true;
}
