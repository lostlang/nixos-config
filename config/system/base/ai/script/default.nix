{
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    (pkgs.callPackage ./get-openrouter-models.nix { })
  ];
}
