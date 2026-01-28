{
  colorScheme,
  config,
  pkgs,
  ...
}:
let
  aiderw = pkgs.callPackage ./aiderw.nix { inherit colorScheme; };

  mkAiderw = pkgs.callPackage ./aiderw-template.nix { inherit aiderw config; };
  mkAiderwTmp = pkgs.callPackage ./aiderw-tmp-template.nix { };

  provider = config.myConfig.ai.provider;
  providerNames = builtins.attrNames provider;
  enabledProviderNames = builtins.filter (name: provider.${name}.enable) providerNames;

  generatedAiderwScripts = map (name: mkAiderw { inherit name; }) enabledProviderNames;
  generatedAiderwTmpScripts = map (name: mkAiderwTmp { inherit name; }) enabledProviderNames;
in
{
  environment.systemPackages = generatedAiderwScripts ++ generatedAiderwTmpScripts;
}
