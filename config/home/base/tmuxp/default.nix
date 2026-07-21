{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.tmuxp ];

  xdg.configFile."tmuxp/dev.yaml".source = ./dev.yaml;
}
