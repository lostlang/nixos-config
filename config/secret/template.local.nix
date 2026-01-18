{
  # e.g., use `openssl rand -base64 64` to generate
  openWebui = {
    webuiSecretKey = "";
    oauthSessionTokenEncryptionKey = "";
  };

  apiKey = {
    llm = {
      free = {
        # https://openrouter.ai/settings/keys
        openrouter = "";
      };
      paid = {
        # https://platform.openai.com/account/api-keys
        openai = "";

        # https://openrouter.ai/settings/keys
        openrouter = "";

        # https://z.ai/manage-apikey/apikey-list
        zai = "";
      };
    };
  };

  zerotier = {
    # https://central.zerotier.com
    joinNetworks = [ ];

    # use `sudo zerotier-cli listnetworks`
    interface = {
      minecraft = "";
    };
  };
}
