{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    codex
    git
    home-manager
    lazygit
    microfetch
    neofetch
    openssh
    pre-commit
    unzip
    wget
    zip
    zsh
  ];
}
