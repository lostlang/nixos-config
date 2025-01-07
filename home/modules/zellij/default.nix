{ lib, ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      default_mode = "locked";
      theme = "lostsand";
      themes = {
        lostsand = {
          fg = "#437F06";
          bg = "#DAB97C";
          white = "#10072B";
          red = "#EDDFBF";
          orange = "#A8460B";
          yellow = "#9B8318";
          green = "#437F06";
          cyan = "#0B8C5F";
          blue = "#23569F";
          magenta = "#991294";
          black = "#EDDFBF";
        };
      };
      keybinds = {
        locked = {
          "bind \"Ctrl t\"" = {
            GoToNextTab = { };
          };
        };
      };
    };
  };

  home.file.".config/zellij/layouts".source = ./layouts;
}
