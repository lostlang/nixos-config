{
  config,
  lib,
  ...
}:
lib.mkIf config.services.vaultwarden.enable {
  sops = {
    secrets."vaultwarden.admin-token" = { };

    templates."vaultwarden.env" = {
      content = ''
        ADMIN_TOKEN=${config.sops.placeholder."vaultwarden.admin-token"}
      '';
    };
  };

  services.vaultwarden.environmentFile = [ config.sops.templates."vaultwarden.env".path ];
}
