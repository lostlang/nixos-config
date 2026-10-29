{
  config,
  lib,
  ...
}:
lib.mkIf config.services.openbao.enable {
  sops.secrets."openbao.unseal-key" = { };

  sops.templates."openbao.env" = {
    content = ''
      BAO_STATIC_UNSEAL_KEY=${config.sops.placeholder."openbao.unseal-key"}
      BAO_API_ADDR=https://${config.sops.placeholder."domain.openbao"}
    '';
  };

  systemd.services.openbao.serviceConfig.EnvironmentFile = config.sops.templates."openbao.env".path;
}
