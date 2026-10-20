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
    cloudflare = {
      enable = true;
      tunnels = [ "test" ];
    };
    zerotierone = {
      enable = true;
      interfaces = [ "game" ];
    };
    keyd.enable = true;
    sunshine.enable = true;
  };
}
