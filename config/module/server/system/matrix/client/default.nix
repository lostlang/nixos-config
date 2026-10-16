{
  config,
  lib,
  pkgs,
  ports,
  ...
}:
let
  cfg = config.services.matrix.client;
  webService = import ../../../web-service.nix { inherit lib pkgs; };
in
{
  imports = [
    ./traefik.nix
  ];

  options.services.matrix.client = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (config.services.matrix-tuwunel.enable && cfg.enable) (
    lib.mkMerge [
      (webService {
        name = "element-web";
        package = pkgs.element-web;
        configFile = config.sops.templates."element-web-config.json".path;
        port = ports.matrix.client;
      })

      {
        sops.templates."element-web-config.json" = {
          mode = "0444";
          content = builtins.toJSON {
            default_server_config."m.homeserver".base_url = "https://${
              config.sops.placeholder."domain.matrix.server"
            }";
            default_server_name = config.sops.placeholder."domain.matrix.server";
            disable_custom_urls = true;
          };
        };
      }
    ]
  );
}
