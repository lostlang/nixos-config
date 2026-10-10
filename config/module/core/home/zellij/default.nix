{
  colorScheme,
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  themeName = colorScheme.default.name;
  theme = import ./theme.nix { inherit colorScheme; };
  codeLayout = import ./layouts/code.nix { inherit colorScheme osConfig; };
in
{
  home.packages = [
    (import ./zellij-project.nix {
      inherit lib pkgs;
      zellij = config.programs.zellij.package;
    })
    (import ./zellij-sessions.nix {
      inherit lib pkgs;
      zellij = config.programs.zellij.package;
    })
  ];

  programs.zellij = {
    enable = true;

    settings = {
      # default_mode = "locked";
      # pane_frames = false;
      theme = themeName;
      themes = {
        ${themeName} = theme;
      };
      # keybinds = {
      #   locked = {
      #     "bind \"Ctrl t\"" = {
      #       GoToNextTab = { };
      #     };
      #   };
      # };
    };
  };

  xdg.configFile."zellij/layouts/code.kdl" = lib.mkIf config.programs.zellij.enable {
    text = codeLayout;
  };
}
