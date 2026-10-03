{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    age
    bitwarden-cli
    home-manager
    microfetch
    openssl
    python3
    ripgrep
    sops
    unzip
    wget
    zip
  ];
}
