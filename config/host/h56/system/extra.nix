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
    local-fw.enable = lib.mkForce true;
  };
}
