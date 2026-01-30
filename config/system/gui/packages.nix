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
    obsidian
    telegram-desktop
    thunar
    udiskie
    waybar
    wl-clipboard
  ];
}
