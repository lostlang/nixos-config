{
  colorScheme,
  config,
  lib,
  osConfig,
  ...
}:
let
  themeName = colorScheme.default.name;
  theme = import ./theme.nix { inherit colorScheme; };
  codeLayout = import ./layouts/code.nix { inherit colorScheme osConfig; };
in
{
  programs.zellij = {
    enable = false;

    settings = {
      default_mode = "locked";
      pane_frames = false;
      theme = themeName;
      themes = {
        ${themeName} = theme;
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

  xdg.configFile."zellij/layouts/code.kdl" = lib.mkIf config.programs.zellij.enable {
    text = codeLayout;
  };
}
