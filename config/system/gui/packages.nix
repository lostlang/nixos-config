{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    blueman
    godot_4
    imv
    kdePackages.kdenlive
    networkmanagerapplet
    obsidian
    telegram-desktop
    thunar
    transmission_4-qt
    udiskie
    vlc
    waybar
    wl-clipboard
  ];
}
