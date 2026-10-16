{
  services = {
    adguardhome.enable = true;
    matrix-tuwunel.enable = true;
    matrix = {
      client.enable = true;
      admin.enable = true;
    };
    remnawave-panel = {
      enable = true;
      nodes = {
        basic = [ "vps15358d36" ];
        hopping = [ "vps72c411b0" ];
      };
    };
    remnawave-node = {
      enable = true;
      hopping = {
        enable = true;
        availableNodeCount = 1;
      };
    };
    vaultwarden.enable = true;
  };
}
