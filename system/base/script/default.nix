{ pkgs, ... }:
{
  environment.systemPackages = [
    (import ./clean_script.nix { inherit pkgs; })
    (import ./init_env.nix { inherit pkgs; })
    (import ./minecraft_data_copy.nix { inherit pkgs; })
    (import ./ollama_model_tester.nix { inherit pkgs; })
    (import ./steam_clip_builder.nix { inherit pkgs; })
  ];
}
