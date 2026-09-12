{
  lib,
  ...
}:
{
  imports = [
    ../../script/fmt-staged.nix
    ../../script/rebuild-vps.nix
  ];

  stylix.enable = lib.mkForce true;
}
