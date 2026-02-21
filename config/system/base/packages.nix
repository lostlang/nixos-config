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
    neofetch
    pre-commit
    ripgrep
    sops
    tree
    unzip
    wget
    zip
  ];
}
