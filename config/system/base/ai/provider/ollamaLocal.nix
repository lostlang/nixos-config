{
  lib,
  ...
}:
let
  provider = {
    enable = false;
    apiBase = "http://127.0.0.1:11434/v1";
    model = {
      prefix = "ollama";
      default = "qwen3.5:2b";
      weak = "qwen3.5:0.8b";
      embedding = [
        {
          type = "embedding";
          name = "bge-m3";
          max_tokens_per_chunk = 8191;
          input_price = 0;
        }
        {
          type = "embedding";
          name = "nomic-embed-text-v2-moe";
          max_tokens_per_chunk = 511;
          input_price = 0;
        }
        {
          type = "embedding";
          name = "qwen3-embedding:0.6b";
          max_tokens_per_chunk = 32767;
          input_price = 0;
        }
      ];
      chat = [
        {
          name = "qwen3.5:0.8b";
          input_price = 0;
          output_price = 0;
        }
        {
          name = "qwen3.5:2b";
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
    };
  };
in
{
  options.myConfig.ai.provider.ollamaLocal = lib.mkOption {
    type = lib.types.attrs;
    default = provider;
    apply = v: lib.recursiveUpdate provider v;
  };
}
