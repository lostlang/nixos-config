{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    age
    codex
    home-manager
    microfetch
    neofetch
    pre-commit
    ripgrep
    sops
    unzip
    wget
    zip
  ];
}
