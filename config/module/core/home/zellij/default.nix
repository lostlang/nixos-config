{
  colorScheme,
  config,
  lib,
  pkgs,
  zjstatus,
  ...
}:
let
  themeName = colorScheme.default.name;
  theme = import ./theme.nix { inherit colorScheme; };
  zjstatusPackage = zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default;

  codeLayout = import ./layout/code.nix {
    inherit colorScheme config lib;
    zjstatus = zjstatusPackage;
  };
  resurrectCommandHook = pkgs.writeShellScript "zellij-resurrect-command" /* sh */ ''
    case "$RESURRECT_COMMAND" in
      sudo|sudo\ *|*/sudo|*/sudo\ *)
        printf '%s\n' "$SHELL"
        ;;
      nvim|nvim\ *|*/nvim|*/nvim\ *)
        printf '%s\n' 'nvim .'
        ;;
      *)
        printf '%s\n' "$RESURRECT_COMMAND"
        ;;
    esac
  '';
in
{
  programs.zellij = {
    enable = true;

    settings = {
      pane_frames = false;
      show_release_notes = false;
      show_startup_tips = false;
      # NOTE: zellij strange save session
      # sometimes with full path to nix store
      # don't work correctly with aliases like codex2(config/module/core/home/zsh/aliases.nix:12)
      post_command_discovery_hook = "${resurrectCommandHook}";
      theme = themeName;
      themes = {
        ${themeName} = theme;
      };
      plugins = {
        "session-manager location=\"zellij:session-manager\"" = {
          multi_screen = true;
        };
        "autolock location=\"https://github.com/fresh2dev/zellij-autolock/releases/latest/download/zellij-autolock.wasm\"" =
          {
            is_enabled = true;
            lock_regex = "^(vim|nvim|hx|fzf|tmux|ssh)$";
          };
      };
      load_plugins = {
        autolock = { };
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

  home.packages = lib.mkIf config.programs.zellij.enable [
    (import ./zellij-project.nix {
      inherit lib pkgs;
      zellij = config.programs.zellij.package;
    })
    (import ./zellij-sessions.nix {
      inherit lib pkgs;
      zellij = config.programs.zellij.package;
    })
  ];

  xdg.configFile."zellij/layouts/code.kdl" = lib.mkIf config.programs.zellij.enable {
    text = codeLayout;
  };
  xdg.configFile."zellij/permissions.kdl" = lib.mkIf config.programs.zellij.enable {
    text = ''
      "${zjstatusPackage}/bin/zjstatus.wasm" {
        ReadApplicationState
        ChangeApplicationState
        RunCommands
      }
      "https://github.com/fresh2dev/zellij-autolock/releases/latest/download/zellij-autolock.wasm" {
        ReadApplicationState
        ChangeApplicationState
      }
    '';
  };

  home.activation.zjstatusPermissions = lib.mkIf config.programs.zellij.enable (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run mkdir -p ${lib.escapeShellArg "${config.xdg.cacheHome}/zellij"}
      run cp --remove-destination \
        ${lib.escapeShellArg "${config.xdg.configHome}/zellij/permissions.kdl"} \
        ${lib.escapeShellArg "${config.xdg.cacheHome}/zellij/permissions.kdl"}
      run chmod 644 ${lib.escapeShellArg "${config.xdg.cacheHome}/zellij/permissions.kdl"}
    ''
  );
}
