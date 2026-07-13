args:
let
  mkProvider = import ./mkProvider.nix;

  providerFree = {
    enable = false;
    apiBase = "https://openrouter.ai/api/v1";
    model = {
      prefix = "openai";
      default = "";
      weak = "";
      embedding = [ ];
      chat = [
        {
          name = "moonshotai/kimi-k2.6:free";
          max_input_tokens = 262143;
          max_output_tokens = 262143;
          input_price = 0;
          output_price = 0;
        }
        {
          name = "qwen/qwen3-next-80b-a3b-instruct:free";
          max_input_tokens = 262143;
          max_output_tokens = 262143;
          input_price = 0;
          output_price = 0;
        }
      ];
    };
  };

  providerPaid = {
    enable = false;
    apiBase = "https://openrouter.ai/api/v1";
    model = {
      prefix = "openai";
      default = "";
      weak = "";
      embedding = [
        {
          type = "embedding";
          name = "qwen/qwen3-embedding-8b";
          max_tokens_per_chunk = 32767;
          max_batch_size = 100;
          input_price = 1.0e-2;
        }
      ];
      chat = [
        {
          name = "qwen/qwen-turbo";
          max_input_tokens = 262143;
          max_output_tokens = 262143;
          input_price = 5.0e-2;
          output_price = 0.2;
        }
      ];
    };
  };
in
{
  imports = [
    (
      (mkProvider {
        name = "openrouterFree";
        provider = providerFree;
      })
      args
    )
    (
      (mkProvider {
        name = "openrouterPaid";
        provider = providerPaid;
      })
      args
    )
  ];
}
