{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    age
    home-manager
    microfetch
    openssl
    ripgrep
    sops
    unzip
    wget
    zip
  ];
}
