{ secret, ... }:
{
  assertions = [
    {
      assertion = secret.openWebui.webuiSecretKey != "";
      message = "open-webui: WEBUI_SECRET_KEY пуст — заполни secret/local.nix";
    }
    {
      assertion = secret.openWebui.oauthSessionTokenEncryptionKey != "";
      message = "open-webui: OAUTH_SESSION_TOKEN_ENCRYPTION_KEY пуст — заполни secret/local.nix";
    }
  ];

  services.ollama = {
    enable = true;

    host = "0.0.0.0";

    loadModels = [
      "bge-m3"
      "qwen3-embedding:0.6b"

      "qwen3:0.6b"
      "qwen3:1.7b"

      "qwen2.5-coder:0.5b"
      "qwen2.5-coder:1.5b"
    ];
  };

  services.open-webui = {
    enable = true;

    host = "0.0.0.0";
    port = 11435;

    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      WEBUI_SECRET_KEY = secret.openWebui.webuiSecretKey;
      OAUTH_SESSION_TOKEN_ENCRYPTION_KEY = secret.openWebui.oauthSessionTokenEncryptionKey;
      PORT = "11435";
    };
  };
}
