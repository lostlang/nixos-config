{
  ...
}@args:
let
  mkProvider = import ./mkProvider.nix;

  provider = {
    enable = false;
    apiBase = "https://api.z.ai/api/coding/paas/v4";
    model = {
      prefix = "openai";
      default = "glm-4.7";
      weak = "glm-4.7-flash";
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
          name = "glm-4.7-flash";
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
in
(mkProvider {
  name = "zai";
  provider = provider;
})
  args
