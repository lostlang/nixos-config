{
  pkgs,
  ...
}:
{
  stylix.enable = true;

  environment.systemPackages = with pkgs; [
    gitleaks
  ];
}
