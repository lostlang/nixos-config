{
  pkgs,
  ...
}:
{
  stylix.enable = true;
  programs.openbao-client.enable = true;

  environment.systemPackages = with pkgs; [
    gitleaks
  ];
}
