let
  local = import /home/lostlang/.config/nixos/config/secret/local.nix;
in
{
  openWebui = {
    webuiSecretKey = local.openWebui.webuiSecretKey or "";
    oauthSessionTokenEncryptionKey = local.openWebui.oauthSessionTokenEncryptionKey or "";
  };

  apiKey = {
    llm = {
      free = {
        openrouter = local.apiKey.llm.free.openrouter or "";
      };
      paid = {
        openai = local.apiKey.llm.paid.openai or "";
        openrouter = local.apiKey.llm.paid.openrouter or "";
        zai = local.apiKey.llm.paid.zai or "";
      };
    };
  };

  zerotier = {
    joinNetworks = local.zerotier.join_networks or [ ];

    interface = {
      minecraft = local.zerotier.interfaces.minecraft or "";
    };
  };
}
