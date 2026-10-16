{
  config,
  lib,
  ports,
  ...
}:
{
  imports = [
    ./sops.nix
    ./traefik.nix
  ];

  services.matrix-tuwunel = {
    enable = lib.mkDefault false;

    environmentFile = config.sops.templates."tuwunel.env".path;

    settings.global = {
      server_name = "localhost";
      port = [ ports.matrix.server ];

      allow_registration = lib.mkDefault true;
      registration_token_file = config.sops.secrets."tuwunel.registration-token".path;
    };
  };
}
