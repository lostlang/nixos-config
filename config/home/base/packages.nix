{
  pkgs,
  ...
}:
{
  programs.bat.enable = true;
  programs.lazygit.enable = true;

  home.packages = with pkgs; [
  ];
}
