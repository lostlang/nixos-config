{ secret, ... }:
let
  hasOpenrouterPaid = secret.openrouter.apiKeys.paid != "";
  hasOpenaiPaid = secret.openai.apiKeys.paid != "";
in
{
  assertions = [
    {
      assertion = secret.openrouter.apiKeys.free != "";
      message = "OpenRouter free API key is not set in secret/local.nix";
    }
  ];

  programs.aichat = {
    enable = true;

    settings = {
      model = "openrouter-free:xiaomi/mimo-v2-flash:free";

      rag_top_k = 20;

      clients = [
        {
          name = "openrouter-free";
          type = "openai-compatible";
          api_base = "https://openrouter.ai/api/v1";
          api_key = secret.openrouter.apiKeys.free;
          models = [
            {
              name = "xiaomi/mimo-v2-flash:free";
              max_input_tokens = 262143;
              max_output_tokens = 65535;
              input_price = 0;
              output_price = 0;
            }

            {
              name = "mistralai/devstral-2512:free";
              max_input_tokens = 262143;
              max_output_tokens = 262143;
              input_price = 0;
              output_price = 0;
            }
            {
              name = "qwen/qwen3-coder:free";
              max_input_tokens = 262143;
              max_output_tokens = 262143;
              input_price = 0;
              output_price = 0;
            }
          ];
        }

        {
          name = "ollama";
          type = "openai-compatible";
          api_base = "http://127.0.0.1:11434/v1";
          models = [
            {
              type = "embedding";
              name = "bge-m3";
              max_tokens_per_chunk = 8191;
              default_chunk_overlay = 150;
              input_price = 0;
            }
            {
              type = "embedding";
              name = "qwen3-embedding:0.6b";
              max_tokens_per_chunk = 32767;
              default_chunk_overlay = 150;
              input_price = 0;
            }

            {
              name = "qwen3:0.6b";
              input_price = 0;
              output_price = 0;
            }
            {
              name = "qwen3:1.7b";
              input_price = 0;
              output_price = 0;
            }
            {
              name = "qwen2.5-coder:0.5b";
              input_price = 0;
              output_price = 0;
            }
            {
              name = "qwen2.5-coder:1.5b";
              input_price = 0;
              output_price = 0;
            }
          ];
        }
      ]
      ++ (
        if hasOpenrouterPaid then
          [
            {
              name = "openrouter-paid";
              type = "openai-compatible";
              api_base = "https://openrouter.ai/api/v1";
              api_key = secret.openrouter.apiKeys.paid;
              models = [
                {
                  type = "embedding";
                  name = "qwen/qwen3-embedding-8b";
                  max_tokens_per_chunk = 32767;
                  max_batch_size = 100;
                  input_price = 1.0e-2;
                }
              ];
            }
          ]
        else
          [ ]
      )
      ++ (
        if hasOpenaiPaid then
          [
            {
              name = "openai-paid";
              type = "openai-compatible";
              api_base = "https://api.openai.com/v1";
              api_key = secret.openai.apiKeys.paid;
              models = [
                {
                  name = "gpt-5-nano";
                  max_input_tokens = 399999;
                  max_output_tokens = 127999;
                  input_price = 5.0e-2;
                  output_price = 0.4;
                }
              ];
            }
          ]
        else
          [ ]
      );
    };
  };
}
