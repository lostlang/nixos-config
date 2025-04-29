{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    blueman
    godot_4
    kdenlive
    networkmanagerapplet
    obsidian
    steam
    telegram-desktop
    transmission_4-qt
    wl-clipboard
  ];
}
