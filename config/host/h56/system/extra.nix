{
  lib,
  ...
}:
{
  imports = [
    ../../../preset/system/main.nix
  ];

  services = {
    keyd.enable = lib.mkForce true;
  };

  systemd.services.local-fw.enable = lib.mkForce true;
}
