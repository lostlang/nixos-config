{
  config,
  lib,
  ports,
  ...
}:
{
  imports = [
    ./bootstrap.nix
    ./openbao.nix
  ];

  services.traefik.enable = lib.mkIf config.services.vaultwarden.enable true;

  services.vaultwarden = {
    enable = lib.mkDefault false;

    dbBackend = "sqlite";
    backupDir = "/var/backup/vaultwarden";

    config = {
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = ports.vaultwarden;
    };
  };
}
