{
  colorScheme,
  config,
  lib,
  osConfig,
  ...
}:
{
  imports = [
    ./hidden-apps.nix
    ./timezones.nix
    ./shelf.nix
  ];

  stylix.targets.noctalia.enable = false;

  home.activation.clearNoctaliaSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] /* sh */ ''
    run rm -f -- ${lib.escapeShellArg "${config.xdg.stateHome}/noctalia/settings.toml"}
  '';

  programs.noctalia = {
    enable = true;

    customPalettes.${colorScheme.default.name} = import ./theme.nix { inherit colorScheme; };

    settings = {
      hooks.started = lib.optional (
        !osConfig.services.displayManager.noctalia-greeter.enable
      ) "noctalia msg session lock";

      idle = {
        behavior_order = [
          "lock"
          "screen-off"
        ];
        behavior = {
          lock = {
            enabled = lib.mkDefault true;
            timeout = 600;
            action = "lock";
          };
          screen-off = {
            enabled = lib.mkDefault osConfig.services.displayManager.noctalia-greeter.enable;
            timeout = 660;
            locked_timeout = 60;
            action = "screen_off";
          };
        };
      };

      shell = {
        panel_anchor_bar = "default";
        password_style = "random";
        font_family = config.stylix.fonts.monospace.name;
        settings_show_advanced = true;

        screenshot = {
          directory = "${config.home.homeDirectory}/Pictures/Screenshots";
          filename_pattern = "%Y/%m/screenshot_%Y%m%d_%H%M%S";
          show_cursor = false;
        };

        session.actions = [
          {
            action = "lock_and_suspend";
            enabled = true;
            countdown_seconds = 5;
            shortcut = "l";
          }
          {
            action = "reboot";
            enabled = true;
            countdown_seconds = 5;
            shortcut = "r";
          }
          {
            action = "shutdown";
            enabled = true;
            countdown_seconds = 5;
            shortcut = "s";
            variant = "destructive";
          }
        ];
      };

      theme = {
        mode = "light";
        source = "custom";
        custom_palette = colorScheme.default.name;
      };

      lockscreen.transition = [ "honeycomb" ];

      wallpaper = {
        transition = [ "honeycomb" ];
        directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
        automation = {
          enabled = true;
          interval_seconds = 1800;
          order = "random";
        };
      };

      widget = {
        bluetooth.actions.right = "panel-toggle control-center bluetooth";
        network = {
          show_label = false;
          actions.right = "panel-toggle control-center network";
        };
        volume.actions.right = "media toggle";
      };

      bar = {
        order = [
          "default"
          "island"
        ];

        default = {
          smart_auto_hide = true;
          reserve_space = false;
          start = [
            "launcher"
            "workspaces"
          ];
          center = [ ];
          end = [
            "volume"
            "brightness"
            "tray"
            "bluetooth"
            "network"
            "weather"
            "battery"
          ];
        };

        island = {
          shadow = false;
          reserve_space = false;
          margin_ends = 830;
          start = [ ];
          center = [
            "clock-current"
            "notifications"
            "screenshot"
            "clipboard"
            "keyboard_layout"
            "clock-remote"
          ];
          end = [ ];
        };
      };

      location = {
        address = "Boracay, Philippines";
      };

      weather = {
        unit = "metric";
        refresh_minutes = 30;
        effects = true;
      };

      osd = {
        offset_y = 42; # 34px bar + 8px gap.
      };

      notification = {
        position = "top_center";
        offset_y = 42; # 34px bar + 8px gap.
      };
    };
  };
}
