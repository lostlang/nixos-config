{ pkgs, secret, ... }:
{
  assertions = [
    {
      assertion = secret.openrouter.apiKeys.free != "";
      message = "OpenRouter free API key is not set in secret/local.nix";
    }
  ];

  environment.systemPackages = [
    (import ./aiderw.nix { inherit pkgs; })
    (import ./aider-ollama.nix { inherit pkgs; })
    (import ./aiderw-openrouter.nix { inherit pkgs secret; })
    (
      if secret.openai.apiKeys.paid != "" then
        (import ./aiderw-openai.nix { inherit pkgs secret; })
      else
        null
    )
    (if secret.zai.apiKeys.paid != "" then (import ./aiderw-zai.nix { inherit pkgs secret; }) else null)
    (import ./aider-ollama.nix { inherit pkgs secret; })
    (import ./clean_script.nix { inherit pkgs; })
    (import ./env_init.nix { inherit pkgs; })
    (import ./env_rm.nix { inherit pkgs; })
    (import ./minecraft_data_copy.nix { inherit pkgs; })
    (import ./ollama_model_tester.nix { inherit pkgs; })
    (import ./steam_clip_builder.nix { inherit pkgs; })
  ];
}
