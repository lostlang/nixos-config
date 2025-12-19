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

      rag_embedding_model = "ollama:nomic-embed-text:latest";

      clients = [
        {
          name = "openrouter";
          type = "openai-compatible";
          api_base = "https://openrouter.ai/api/v1";
          api_key = secret.openrouter.api_key;
          models = [ { name = "mistralai/devstral-2512"; } ];
        }

        {
          name = "ollama";
          type = "openai-compatible";
          api_base = "http://127.0.0.1:11434/v1";
          models = [
            {
              type = "embedding";
              name = "nomic-embed-text:latest";
              max_tokens_per_chunk = 2048;
              default_chunk_size = 500;
            }
          ];
        }
      ];
    };
  };

  home.file.".config/aichat/macros".source = ./macros;
}
