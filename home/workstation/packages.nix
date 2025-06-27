{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    blueman
    godot_4
    kdePackages.kdenlive
    networkmanagerapplet
    obsidian
    vlc
    telegram-desktop
    transmission_4-qt
    wl-clipboard
  ];
}
