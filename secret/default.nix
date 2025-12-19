let
  local = import /home/lostlang/.config/nixos/secret/local.nix;
in
{
  openWebui = {
    webuiSecretKey = local.openWebui.webuiSecretKey or "";
    oauthSessionTokenEncryptionKey = local.openWebui.oauthSessionTokenEncryptionKey or "";
  };
  openrouter.api_key = local.openrouter.api_key or "";
}
