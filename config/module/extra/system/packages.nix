{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    gitleaks
    lazygit
    tree
  ];
}
