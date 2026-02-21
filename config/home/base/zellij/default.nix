{
  colorScheme,
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
    enable = true;
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

  xdg.configFile."zellij/layouts/code.kdl".text = codeLayout;
}
