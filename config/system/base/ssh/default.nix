{
  imports = [
    ./options.nix
    ./sops.nix
  ];

  services.openssh = {
    enable = true;

    settings.PasswordAuthentication = false;
  };
}
