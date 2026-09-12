{
  extraLocalModules,
  ...
}:
{
  imports = [
    ./secret
    ./ssh

    ./docker.nix
    ./localization.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./security.nix
    ./timezone.nix
    ./user.nix
    ./xdg-portal.nix
  ]
  ++ map (name: ../../${name}/system) extraLocalModules;
}
