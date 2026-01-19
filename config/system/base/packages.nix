{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    codex
    home-manager
    microfetch
    neofetch
    pre-commit
    unzip
    wget
    zip
  ];
}
