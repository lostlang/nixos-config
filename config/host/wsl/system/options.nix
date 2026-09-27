{
  config.myConfig = {
    ai.provider = {
      ollamaLocal.enable = true;

      openrouterFree.enable = true;
      zai.enable = true;
    };
    ssh = {
      hosts = [
        "h56"
      ];
      vpsHosts = [
        "vps15358d36"
        "vps72c411b0"
      ];
    };
  };
}
