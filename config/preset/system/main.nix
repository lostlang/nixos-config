{
  pkgs,
  ...
}:
{
  imports = [
    ../../script/env-init
    ../../script/fmt-staged
    ../../script/rebuild-vps
  ];

  stylix.enable = true;

  environment.systemPackages = with pkgs; [
    gitleaks
  ];
}
