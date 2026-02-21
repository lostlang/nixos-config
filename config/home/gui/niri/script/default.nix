{
  pkgs,
  ...
}:
{
  home.packages = [
    (pkgs.callPackage ./resolution_swich.nix { })
  ];
}
