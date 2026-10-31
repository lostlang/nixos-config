{
  lib,
  user,
  ...
}:
{
  virtualisation.docker = {
    enable = lib.mkDefault true;
    daemon.settings = {
      log-driver = "local";
      log-opts = {
        max-size = "5m";
        max-file = "2";
      };
    };
  };

  users.users.${user}.extraGroups = [ "docker" ];
}
