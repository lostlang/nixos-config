{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    zed-editor
    neofetch
    microfetch
    steam
    telegram-desktop
    transmission_4-qt
  ];
}
