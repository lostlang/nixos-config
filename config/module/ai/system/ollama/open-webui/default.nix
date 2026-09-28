{
  config,
  lib,
  ports,
  ...
}:
let
  enable = config.myConfig.ai.provider.ollamaLocal.enable && config.myConfig.openWebui.enable;
in
{
  imports = [
    ./options.nix
    ./sops.nix
    ./user.nix
  ];

  services.open-webui = lib.mkIf enable {
    enable = true;

    host = "0.0.0.0";
    port = ports.openWebui;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
    };
  };

  systemd.services.open-webui.serviceConfig = lib.mkIf enable {
    EnvironmentFile = config.sops.templates."open-webui.env".path;
    User = "open-webui";
  };
}
