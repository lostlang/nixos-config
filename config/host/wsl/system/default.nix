{
  hostname,
  stateVersion,
  user,
  ...
}:
{
  imports = [
    ./keyd.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = user;

  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
