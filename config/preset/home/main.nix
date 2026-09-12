{
  lib,
  ...
}:
{
  programs.herdr.enable = lib.mkForce true;
  programs.lazygit.enable = lib.mkForce true;
}
