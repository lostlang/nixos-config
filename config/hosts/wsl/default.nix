{
  hostname,
  stateVersion,
  user,
  ...
}:
{
  wsl.enable = true;
  wsl.defaultUser = user;

  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
