{
  lib,
  ...
}:
{
  systemd.tmpfiles.rules = [
    "L+ /usr/bin/whoami - - - - /run/current-system/sw/bin/whoami"
    "L+ /usr/bin/id - - - - /run/current-system/sw/bin/id"
    "L+ /usr/bin/groups - - - - /run/current-system/sw/bin/groups"
    "L+ /usr/bin/getent - - - - /run/current-system/sw/bin/getent"
  ];

  virtualisation.docker.enable = lib.mkForce false;
}
