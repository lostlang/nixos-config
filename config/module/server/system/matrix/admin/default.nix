{
  config,
  lib,
  pkgs,
  ports,
  ...
}:
let
  webService = import ../../../web-service.nix { inherit lib pkgs; };
in
{
  options.services.matrix.admin.enable =
    lib.mkEnableOption "Synapse Admin web interface for the Matrix server";

  config = lib.mkIf (config.services.matrix-tuwunel.enable && config.services.matrix.admin.enable) (
    lib.mkMerge [
      (webService {
        name = "synapse-admin";
        package = pkgs.synapse-admin;
        configFile = config.sops.templates."synapse-admin-config.json".path;
        port = ports.matrix.admin;
      })

      {
        sops.templates."synapse-admin-config.json" = {
          mode = "0444";
          content = builtins.toJSON {
            restrictBaseUrl = "https://${config.sops.placeholder."domain.matrix.server"}";
          };
        };
      }
    ]
  );
}
