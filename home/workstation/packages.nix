{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    wl-clipboard
    steam
    telegram-desktop
    transmission_4-qt
    kdenlive

    godot_4
  ];
}
