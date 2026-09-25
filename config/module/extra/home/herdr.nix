{
  colorScheme,
  lib,
  ...
}:
let
  inherit (colorScheme.default) palette;
in
{
  programs.herdr = {
    enable = lib.mkDefault false;

    settings = {
      onboarding = false;
      theme = {
        name = "terminal";
        auto_switch = false;

        custom = {
          accent = palette.green;
          panel_bg = palette.light_white;
          surface0 = palette.light_white;
          surface1 = palette.gradient.light.g2;
          surface_dim = palette.gradient.light.g3;
          overlay0 = palette.gradient.light.g4;
          overlay1 = palette.light_black;
          text = palette.black;
          subtext0 = palette.light_black;
          inherit (palette)
            blue
            green
            red
            yellow
            ;
          mauve = palette.purple;
          peach = palette.orange;
          teal = palette.aqua;
        };
      };
      ui = {
        hide_tab_bar_when_single_tab = true;
        pane_borders = false;
        prompt_new_tab_name = false;
        sidebar_start_collapsed = true;
      };
    };
  };
}
