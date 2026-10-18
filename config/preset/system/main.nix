{
  pkgs,
  ...
}:
{
  stylix.enable = true;
  lsp.enable = true;

  environment.systemPackages = with pkgs; [
    gitleaks
  ];
}
