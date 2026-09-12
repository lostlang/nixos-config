{
  config.myConfig = {
    ai.provider = {
      ollamaLocal.enable = true;

      openrouterFree.enable = true;
      zai.enable = true;
    };
    ssh = {
      # identities = [ "work" ];
      vpsHosts = [
        "vps15358d36"
        "vps72c411b0"
      ];
    };
  };
}
