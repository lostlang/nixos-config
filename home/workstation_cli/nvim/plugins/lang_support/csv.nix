{ pkgs, ... }:
{
  programs.nixvim.plugins.csvview = {
    enable = true;

    settings = {
      view = {
        display_mode = "border";
        spacing = 4;
        header_lnum = 1;
      };
    };
  };
}
