{
  services = {
    adguardhome.enable = true;
    cloudflare = {
      enable = true;
      tunnels = [ "vps72c411b0" ];
    };
    openbao.enable = true;
    remnawave-node = {
      enable = true;
      hopping = {
        enable = true;
        availableNodeCount = 1;
      };
    };
    remnawave-panel = {
      enable = true;
      nodes = {
        basic = [ "vps15358d36" ];
        hopping = [ "vps72c411b0" ];
      };
    };
    vaultwarden.enable = true;
  };
}
