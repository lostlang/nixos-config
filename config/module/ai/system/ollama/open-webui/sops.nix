{
  config,
  lib,
  ...
}:
let
  enable = config.myConfig.ai.provider.ollamaLocal.enable && config.myConfig.openWebui.enable;
in
{
  sops = lib.mkIf enable {
    secrets = {
      "openWebui.webuiSecretKey" = {
        owner = "open-webui";
      };
      "openWebui.oauthSessionTokenEncryptionKey" = {
        owner = "open-webui";
      };
    };

    templates."open-webui.env" = {
      owner = "open-webui";
      restartUnits = [ "open-webui.service" ];
      content = ''
        WEBUI_SECRET_KEY=${config.sops.placeholder."openWebui.webuiSecretKey"}
        OAUTH_SESSION_TOKEN_ENCRYPTION_KEY=${
          config.sops.placeholder."openWebui.oauthSessionTokenEncryptionKey"
        }
      '';
    };
  };
}
