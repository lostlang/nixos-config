{
  imports = [
    ../../../preset/system/main.nix
  ];

  services = {
    keyd.enable = true;
    sunshine.enable = true;
  };

  systemd.services.local-fw.enable = true;
}
