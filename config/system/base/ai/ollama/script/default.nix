{
  config,
  lib,
  pkgs,
  ...
}:
let
  enable = config.myConfig.ai.provider.ollamaLocal.enable;
  provider = config.myConfig.ai.provider.ollamaLocal;
in
{
  environment.systemPackages = lib.mkIf enable [
    (pkgs.callPackage ./ollama-model-tester.nix { inherit provider; })
  ];
}
