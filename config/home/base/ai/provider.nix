{
  ollamaLocal = {
    api_base = "http://127.0.0.1:11434/v1";
    model = {
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

  openrouterFree = {
    api_base = "https://openrouter.ai/api/v1";
    model = {
      default = "xiaomi/mimo-v2-flash:free";
      weak = "";
      embedding = [ ];
      chat = [
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
        {
          name = "z-ai/glm-4.5-air:free";
          max_input_tokens = 127999;
          max_output_tokens = 95999;
          input_price = 0;
          output_price = 0;
        }
      ];
    };
  };

  openrouterPaid = {
    api_base = "https://openrouter.ai/api/v1";
    model = {
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

  openai = {
    api_base = "https://api.openai.com/v1";
    model = {
      default = "gpt-5-nano";
      weak = "";
      embedding = [ ];
      chat = [
        {
          name = "gpt-5-nano";
          max_input_tokens = 399999;
          max_output_tokens = 127999;
          input_price = 5.0e-2;
          output_price = 0.4;
        }
      ];
    };
  };

  zai = {
    api_base = "https://api.z.ai/api/coding/paas/v4";
    model = {
      default = "glm-4.7";
      weak = "glm-4.5-flash";
      embedding = [ ];
      chat = [
        {
          name = "glm-4.7";
          max_input_tokens = 199999;
          max_output_tokens = 127999;
          input_price = 0.6;
          output_price = 2.2;
        }
        {
          name = "glm-4.6";
          max_input_tokens = 199999;
          max_output_tokens = 127999;
          input_price = 0.6;
          output_price = 2.2;
        }
        {
          name = "glm-4.5";
          max_input_tokens = 199999;
          max_output_tokens = 127999;
          input_price = 0.6;
          output_price = 2.2;
        }
        {
          name = "glm-4.5-air";
          max_input_tokens = 127999;
          max_output_tokens = 95999;
          input_price = 0.2;
          output_price = 1.1;
        }
        {
          name = "glm-4.5-flash";
          max_input_tokens = 127999;
          max_output_tokens = 95999;
          input_price = 0;
          output_price = 0;
        }
      ];
    };
  };
}
