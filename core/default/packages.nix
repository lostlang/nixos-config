{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    docker
    git
    home-manager
    openssh
    pre-commit
    unzip
    wget
    zip
    zsh
  ];
}
