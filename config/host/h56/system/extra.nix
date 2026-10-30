{
  imports = [
    ../../../preset/system/main.nix
  ];

  programs = {
    minecraft-data-copy.enable = true;
  };

  networking.firewall.trustedInterfaces = [
    "en*"
    "wl*"
  ];

  services = {
    zerotierone = {
      enable = true;
      interfaces = [ "game" ];
    };
    keyd.enable = true;
    sunshine.enable = true;
  };
}
