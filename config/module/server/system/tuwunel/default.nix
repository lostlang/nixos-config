{
  config,
  lib,
  ports,
  ...
}:
{
  imports = [
    ./openbao.nix
  ];

  services.traefik.enable = lib.mkIf config.services.matrix-tuwunel.enable true;

  services.matrix-tuwunel = lib.mkIf config.services.matrix-tuwunel.enable {
    settings.global = {
      server_name = "localhost";
      port = [ ports.matrix.server ];

      allow_registration = lib.mkDefault true;
    };
  };
}
