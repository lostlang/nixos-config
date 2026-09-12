{
  imports = [
    ./adguardhome
    ./remnawave

    ./weekly-reboot.nix
    ./traefik.nix
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
