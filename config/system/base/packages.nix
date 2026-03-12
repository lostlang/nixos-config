{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    age
    codex
    gitleaks
    home-manager
    microfetch
    pre-commit
    ripgrep
    sops
    tree
    unzip
    wget
    zip
  ];
}
