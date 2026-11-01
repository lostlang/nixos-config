{ lib, ... }:
{
  imports = [
    ./sops.nix
  ];

  options.myConfig.ssh = {
    identities = lib.mkOption {
      description = "SSH host names whose private keys and host addresses are loaded from SOPS.";
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    hosts = lib.mkOption {
      description = "SSH host names whose addresses are loaded from SOPS.";
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config.services.openssh = {
    enable = true;
    openFirewall = true;

    settings.PasswordAuthentication = false;
  };
}
