{
  config,
  lib,
  ...
}:
let
  cfg = config.services.matrix-tuwunel;
in
lib.mkIf cfg.enable {
  sops = {
    secrets = {
      "domain.matrix.server" = { };
      "tuwunel.registration-token" = {
        owner = cfg.user;
        restartUnits = [ "tuwunel.service" ];
      };
    };

    templates."tuwunel.env" = {
      restartUnits = [ "tuwunel.service" ];
      content = ''
        TUWUNEL_SERVER_NAME=${config.sops.placeholder."domain.matrix.server"}
        TUWUNEL_WELL_KNOWN__CLIENT=https://${config.sops.placeholder."domain.matrix.server"}
        TUWUNEL_WELL_KNOWN__SERVER=${config.sops.placeholder."domain.matrix.server"}:443
      '';
    };
  };
}
