{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    microfetch
    neofetch
    lazygit
  ];
}
