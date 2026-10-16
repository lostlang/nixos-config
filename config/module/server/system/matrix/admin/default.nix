{
  config,
  lib,
  pkgs,
  ports,
  ...
}:
let
  cfg = config.services.matrix.admin;
  webService = import ../../../web-service.nix { inherit lib pkgs; };
in
{
  options.services.matrix.admin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (config.services.matrix-tuwunel.enable && cfg.enable) (
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
