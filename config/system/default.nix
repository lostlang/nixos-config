{
  extraLocalModules,
  ...
}:
{
  imports = [
    ./base
  ]
  ++ map (name: ./${name}) extraLocalModules;
}
