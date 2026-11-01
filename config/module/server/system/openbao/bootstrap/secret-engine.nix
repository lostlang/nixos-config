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
    }
    // lib.genAttrs (map (host: "${host}_node_domain") vpsHostnames) (_: "");
  }
  // lib.listToAttrs (
    map (host: {
      name = "server/${host}";
      value = {
        server_ip = "";
        remnawave_app_secret.random.length = 64;
        remnawave_api_token = "";
        tuwunel_registration_token.random.length = 64;
        vaultwarden_admin_token = "";
      };
    }) vpsHostnames
  );
}
