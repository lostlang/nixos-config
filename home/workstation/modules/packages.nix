{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    zed-editor
    steam
    telegram-desktop
    transmission_4-qt
    kdenlive
  ];
}
