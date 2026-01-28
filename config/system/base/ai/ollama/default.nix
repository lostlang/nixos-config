{
  config,
  lib,
  ...
}:
let
  enable = config.myConfig.ai.provider.ollamaLocal.enable;
  models = config.myConfig.ai.provider.ollamaLocal.model;
  loadModels = (map (m: m.name) models.embedding ++ map (m: m.name) models.chat);
in
{
  imports = [
    ./open-webui
    ./script
  ];

  services.ollama = lib.mkIf enable {
    enable = true;

    host = "0.0.0.0";
    loadModels = loadModels;
  };
}
