{
  lib,
  osConfig,
  ...
}:
let
  provider = osConfig.myConfig.ai.provider;
  providerDefs = builtins.filter (p: p != null) (
    map (
      name:
      let
        p = provider.${name};
      in
      {
        inherit name;
        enable = p.enable;
        api_base = p.apiBase;
        models = p.model.embedding ++ p.model.chat;
      }
    ) (builtins.attrNames provider)
  );
  enabledProviders = builtins.filter (p: p.enable) providerDefs;
  anyEnabled = enabledProviders != [ ];
in
{
  home.sessionVariables = {
    AICHAT_ENV_FILE = osConfig.sops.templates."ai-provider.env".path;
  };

  programs.aichat = lib.mkIf anyEnabled {
    enable = true;

    settings = {
      model = "zai:${provider.zai.model.default}";

      rag_top_k = 20;

      clients = map (p: {
        type = "openai-compatible";
        name = p.name;
        api_base = p.api_base;
        models = p.models;
      }) enabledProviders;
    };
  };
}
