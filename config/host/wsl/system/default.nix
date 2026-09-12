{
  hostname,
  stateVersion,
  user,
  ...
}:
{
  imports = [
    ./extra.nix
    ./fix.nix
    ./options.nix
  ];

  wsl = {
    enable = true;
    defaultUser = user;
  };

  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
