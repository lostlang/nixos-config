{
  config,
  lib,
  ...
}:
let
  enable = (config.myConfig.ai.provider.ollamaLocal.enable && config.myConfig.openWebui.enable);
in
{
  users = lib.mkIf enable {
    users.open-webui = {
      isSystemUser = true;
      group = "open-webui";
    };
    groups.open-webui = { };
  };
}
