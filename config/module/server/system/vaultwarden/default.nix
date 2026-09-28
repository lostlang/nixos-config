{
  lib,
  ports,
  ...
}:
{
  imports = [
    ./sops.nix
    ./traefik.nix
  ];

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
