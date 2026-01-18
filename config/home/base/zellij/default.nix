{
  colorScheme,
  timezone,
  ...
}:
let
  themeName = colorScheme.default.name;
  theme = import ./theme.nix { inherit colorScheme; };
  codeLayout = import ./layouts/code.nix { inherit colorScheme timezone; };
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

  home.file.".config/zellij/layouts/code.kdl".text = codeLayout;
}
