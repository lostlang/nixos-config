{
  config,
  pkgs,
  pythonScriptEnv,
  ...
}:
{
  home.packages = [
    (pkgs.callPackage ./make-sandbox.nix {
      inherit config pythonScriptEnv;
    })
  ];
}
