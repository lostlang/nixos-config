{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    codex
    lazygit
    microfetch
    neofetch
  ];
}
