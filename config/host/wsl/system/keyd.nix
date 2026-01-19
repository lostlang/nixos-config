{
  lib,
  ...
}:
{
  services.keyd.enable = lib.mkForce false;
}
