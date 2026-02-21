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

  security.sudo.wheelNeedsPassword = true;

  system.stateVersion = stateVersion;
}
