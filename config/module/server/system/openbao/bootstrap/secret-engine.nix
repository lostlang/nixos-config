{
  lib,
  vpsHostnames,
}:
{
  config = {
    "shared/domain" = {
      adguardhome = "";
      matrix = "";
      vaultwarden = "";
      remnawave_subscription = "";
    };
    "shared/remnawave" = {
      panel_ip = "";
      secret_key = "";
    };
  }
  // lib.listToAttrs (
    map (host: {
      name = "server/${host}";
      value = {
        server_ip = "";
        remnawave_node_domain = "";
        tuwunel_registration_token.random.length = 64;
        vaultwarden_admin_token.random.length = 64;
      };
    }) vpsHostnames
  );
}
