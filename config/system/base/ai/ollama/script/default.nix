{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.myConfig.ai.provider.ollamaLocal) enable;
  provider = config.myConfig.ai.provider.ollamaLocal;
in
{
  environment.systemPackages = lib.mkIf enable [
    (pkgs.callPackage ./ollama-model-tester.nix { inherit provider; })
  ];
}
