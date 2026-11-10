{
  colorScheme,
  config,
  lib,
  pkgs,
  ...
}:
let
  themeName = colorScheme.default.name;
  theme = import ./theme.nix { inherit colorScheme; };
  zjstatusPackage = pkgs.zellijPlugins.zjstatus;

  codeLayout = import ./layout/code.nix {
    inherit colorScheme config lib;
    zjstatus = zjstatusPackage;
  };
in
{
  imports = [
    ./zellij-project.nix
    ./zellij-sessions.nix
  ];

  programs.zellij = {
    enable = true;

    settings = {
      show_release_notes = false;
      show_startup_tips = false;

      pane_frames = false;
      default_mode = "locked";
      session_serialization = false;
      on_force_close = "detach";

      theme = themeName;
      themes = {
        ${themeName} = theme;
      };

      plugins = {
        "session-manager location=\"zellij:session-manager\"" = {
          multi_screen = true;
        };
      };

      keybinds = {
        "shared_except \"locked\"" = {
          "bind \"Ctrl f\"" = {
            "LaunchOrFocusPlugin \"session-manager\"" = {
              floating = true;
            };
          };
          "bind \"Ctrl q\"" = {
            Detach = { };
          };
        };
        session = {
          "bind \"q\"" = {
            Quit = { };
          };
        };
      };
    };
  };

  xdg.configFile."zellij/layouts/code.kdl" = lib.mkIf config.programs.zellij.enable {
    text = codeLayout;
  };
  xdg.configFile."zellij/permissions.kdl" = lib.mkIf config.programs.zellij.enable {
    text = ''
      "${zjstatusPackage}" {
        ReadApplicationState
        ChangeApplicationState
        RunCommands
      }
    '';
  };

  home.activation.zjstatusPermissions = lib.mkIf config.programs.zellij.enable (
    lib.hm.dag.entryAfter [ "linkGeneration" ] /* sh */ ''
      run mkdir -p ${lib.escapeShellArg "${config.xdg.cacheHome}/zellij"}
      run cp --remove-destination \
        ${lib.escapeShellArg "${config.xdg.configHome}/zellij/permissions.kdl"} \
        ${lib.escapeShellArg "${config.xdg.cacheHome}/zellij/permissions.kdl"}
      run chmod 644 ${lib.escapeShellArg "${config.xdg.cacheHome}/zellij/permissions.kdl"}
    ''
  );
}
