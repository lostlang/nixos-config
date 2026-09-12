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
    ./options.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
