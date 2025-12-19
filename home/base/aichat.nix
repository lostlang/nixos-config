{ secret, ... }:
{
  assertions = [
    {
      assertion = secret.openrouter.api_key != "";
      message = "aichat: openrouter API ключ пуст — заполни secret/local.nix";
    }
  ];

  programs.aichat = {
    enable = true;
    settings = {
      model = "openrouter:mistralai/devstral-2512:free";

      clients = [
        {
          name = "openrouter";
          type = "openai-compatible";
          api_base = "https://openrouter.ai/api/v1";
          api_key = secret.openrouter.api_key;
          models = [ { name = "mistralai/devstral-2512"; } ];
        }
      ];
    };
  };
}
