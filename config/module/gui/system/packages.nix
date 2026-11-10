{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    imv
    obs-studio
    obsidian
    telegram-desktop
    thunar
    udiskie
    wl-clipboard
  ];
}
