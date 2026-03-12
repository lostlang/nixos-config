{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    blueman
    imv
    networkmanagerapplet
    obs-studio
    obsidian
    qalculate-gtk
    telegram-desktop
    thunar
    udiskie
    waybar
    wl-clipboard
  ];
}
