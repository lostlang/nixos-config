{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    godot_4
    kdenlive
    steam
    telegram-desktop
    transmission_4-qt
    wl-clipboard
  ];
}
