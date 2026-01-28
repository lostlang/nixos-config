{
  config.myConfig = {
    ai.provider = {
      ollamaLocal.enable = true;

      openai.enable = true;
      openrouterFree.enable = true;
      openrouterPaid.enable = true;
      zai.enable = true;
    };
    cloudflare = {
      enable = true;
      tunnels = [ "test" ];
    };
    openWebui = {
      enable = true;
    };
    zerotierone = {
      enable = true;
      interfaces = [ "game" ];
    };
  };
}
