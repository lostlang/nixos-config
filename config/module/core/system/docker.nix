{
  config,
  lib,
  user,
  ...
}:
{
  virtualisation.docker.enable = true;

  users.users.${user}.extraGroups = lib.mkIf config.virtualisation.docker.enable [ "docker" ];
}
