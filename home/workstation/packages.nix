{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    blueman
    godot_4
    imv
    kdePackages.kdenlive
    networkmanagerapplet
    obsidian
    telegram-desktop
    transmission_4-qt
    vlc
    wl-clipboard
  ];
}
