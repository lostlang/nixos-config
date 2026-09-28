{
  config,
  lib,
  ports,
  remnawaveContainerCommon,
  ...
}:
let
  cfg = config.services.remnawave-node;

  remnawaveNodeMaskContainer = (removeAttrs remnawaveContainerCommon [ "networks" ]) // {
    image = "busybox:1";
    container_name = "remnawave-node-mask";
    hostname = "remnawave-node-mask";
    network_mode = "host";
    command = [
      "httpd"
      "-f"
      "-p"
      "127.0.0.1:${toString ports.remnawave.mask.backend}"
      "-h"
      "/www"
    ];
    volumes = [ "${./static}:/www:ro" ];
    healthcheck = {
      test = [
        "CMD"
        "wget"
        "--spider"
        "-q"
        "http://127.0.0.1:${toString ports.remnawave.mask.backend}"
      ];
      interval = "10s";
      timeout = "3s";
      retries = 3;
    };
  };
in
{
  imports = [
    ./sops.nix
  ];

  _module.args = {
    inherit remnawaveNodeMaskContainer;
  };

  services.traefik = lib.mkIf cfg.enable {
    enable = true;

    staticConfigOptions.entryPoints = {
      web.http.redirections.entryPoint.to = lib.mkForce ":443";

      websecure = {
        address = lib.mkForce "127.0.0.1:${toString ports.remnawave.mask.entryPoint}";
        proxyProtocol.trustedIPs = [ "127.0.0.1/32" ];
      };
    };
  };
}
