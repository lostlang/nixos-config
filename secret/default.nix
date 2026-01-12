let
  local = import /home/lostlang/.config/nixos/secret/local.nix;
in
{
  openWebui = {
    webuiSecretKey = local.openWebui.webuiSecretKey or "";
    oauthSessionTokenEncryptionKey = local.openWebui.oauthSessionTokenEncryptionKey or "";
  };
  openrouter.apiKeys = {
    free = local.openrouter.apiKeys.free or "";
    paid = local.openrouter.apiKeys.paid or "";
  };
  openai.apiKeys.paid = local.openai.apiKeys.paid or "";
  zai.apiKeys.paid = local.zai.apiKeys.paid or "";
  zerotier = {
    join_networks = local.zerotier.join_networks or [ ];
    minecraft_interface = local.zerotier.minecraft_interface or "";
  };
}
