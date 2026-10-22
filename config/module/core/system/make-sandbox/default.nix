{
  pkgs,
  pythonScriptEnv,
  ...
}:
{
  environment.systemPackages = [
    (pkgs.callPackage ./make-sandbox.nix {
      inherit pythonScriptEnv;
    })
  ];
}
