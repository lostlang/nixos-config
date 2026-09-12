{
  config.myConfig = {
    ai.provider = {
      ollamaLocal.enable = true;

      openai.enable = true;
      openrouterFree.enable = true;
      openrouterPaid.enable = true;
      zai.enable = true;
    };
    cloudflare.tunnels = [ "test" ];
    ssh.identities = [ "work" ];
    zerotierone.interfaces = [ "game" ];
  };
}
