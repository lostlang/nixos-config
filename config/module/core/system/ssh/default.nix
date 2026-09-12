{
  imports = [
    ./options.nix
    ./sops.nix
  ];

  services.openssh = {
    enable = true;
    openFirewall = true;

    settings.PasswordAuthentication = false;
  };
}
