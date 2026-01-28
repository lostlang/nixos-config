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
      default = "qwen3:1.7b";
      weak = "qwen3:0.6b";
      embedding = [
        {
          type = "embedding";
          name = "bge-m3";
          max_tokens_per_chunk = 8191;
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
