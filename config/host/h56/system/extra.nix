{
  imports = [
    ../../../preset/system/main.nix
  ];

  programs = {
    minecraft-data-copy.enable = true;
  };

  networking.firewall.trustedInterfaces = [
    "en+"
    "wl+"
  ];

  services = {
    keyd.enable = true;
    sunshine.enable = true;
  };
}
