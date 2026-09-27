{
  config.myConfig = {
    ai.provider = {
      ollamaLocal.enable = true;

      openai.enable = true;
      openrouterFree.enable = true;
      openrouterPaid.enable = true;
      zai.enable = true;
    };
    cloudflare.tunnels = [
      "test"
    ];
    ssh = {
      identities = [
        "work"
      ];
      vpsHosts = [
        "vps15358d36"
        "vps72c411b0"
      ];
    };
    zerotierone.interfaces = [ "game" ];
  };
}
