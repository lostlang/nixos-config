{
  hostname,
  stateVersion,
  user,
  ...
}:
{
  imports = [
    ./options.nix

    ./keyd.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = user;

  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
