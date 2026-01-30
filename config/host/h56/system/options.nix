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
    ssh.keys = [ "work" ];
    zerotierone = {
      enable = true;
      interfaces = [ "game" ];
    };
  };
}
