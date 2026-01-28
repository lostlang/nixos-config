{
  ...
}@args:
let
  mkProvider = import ./mkProvider.nix;

  provider = {
    enable = false;
    apiBase = "https://api.openai.com/v1";
    model = {
      prefix = "openai";
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
in
(mkProvider {
  name = "openai";
  provider = provider;
})
  args
