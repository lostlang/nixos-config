{ pkgs, ... }:
{
  environment.systemPackages = [
    (import ./clean_script.nix { inherit pkgs; })
    (import ./ollama_model_tester.nix { inherit pkgs; })
    (import ./steam_clip_builder.nix { inherit pkgs; })
  ];
}
