{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    xclip
    steam
    telegram-desktop
    transmission_4-qt
    kdenlive

    godot_4
  ];
}
