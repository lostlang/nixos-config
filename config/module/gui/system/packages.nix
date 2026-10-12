{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    imv
    obs-studio
    obsidian
    qalculate-gtk
    telegram-desktop
    thunar
    udiskie
    wl-clipboard
  ];
}
