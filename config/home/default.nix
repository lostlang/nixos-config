{
  extraLocalModules,
  stateVersion,
  user,
  ...
}:
{
  imports = [
    ./base
  ]
  ++ map (name: ./${name}) extraLocalModules;

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    inherit stateVersion;
  };
}
