{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    hyprland
    udiskie
    waybar
    thunar
  ];
}
