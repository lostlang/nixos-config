{
  hostname,
  lib,
  modulesPath,
  stateVersion,
  user,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./extra.nix
    ./fix.nix
    ./hardware-configuration.nix
    ./options.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.enableAllFirmware = lib.mkForce false;

  documentation.enable = lib.mkForce false;

  networking.hostName = hostname;

  security.sudo.wheelNeedsPassword = lib.mkForce false;

  nix.settings.trusted-users = [
    "root"
    user
  ];

  system.stateVersion = stateVersion;
}
