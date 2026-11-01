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
  ];

  myConfig = {
    ssh = {
      hosts = [
        "h56"
      ];
    };
  };

  wsl = {
    enable = true;
    defaultUser = user;
  };

  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
