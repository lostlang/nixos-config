{
  lib,
  user,
  ...
}:
{
  virtualisation.docker.enable = lib.mkDefault true;

  users.users.${user}.extraGroups = [ "docker" ];
}
