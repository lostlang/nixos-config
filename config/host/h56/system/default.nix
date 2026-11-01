{
  hostname,
  stateVersion,
  ...
}:
{
  imports = [
    ./extra.nix
    ./fix.nix
    ./hardware-configuration.nix
  ];

  myConfig = {
    ssh = {
      identities = [
        "work"
      ];
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
