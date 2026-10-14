{
  config,
  colorScheme,
  ...
}:
{
  stylix.targets.noctalia.enable = false;

  programs.noctalia = {
    enable = true;
    customPalettes.${colorScheme.default.name} = import ./theme.nix { inherit colorScheme; };

    settings = {
      hooks.started = [ "noctalia msg session lock" ];

      idle = {
        behavior_order = [
          "lock"
          "screen-off"
        ];
        behavior = {
          lock = {
            enabled = true;
            timeout = 600;
            action = "lock";
          };
          screen-off = {
            enabled = true;
            timeout = 660;
            action = "screen_off";
          };
        };
      };

      shell = {
        panel_anchor_bar = "default";
        font_family = config.stylix.fonts.monospace.name;
        settings_show_advanced = true;

        screenshot.directory = "${config.home.homeDirectory}/Pictures/Screenshots";

        session.actions = [
          {
            action = "lock";
            enabled = true;
            shortcut = "1";
          }
          {
            action = "lock_and_suspend";
            enabled = true;
            countdown_seconds = 5;
            shortcut = "2";
          }
          {
            action = "reboot";
            enabled = true;
            countdown_seconds = 5;
            shortcut = "3";
          }
          {
            action = "shutdown";
            enabled = true;
            countdown_seconds = 5;
            shortcut = "4";
            variant = "destructive";
          }
        ];
      };

      theme = {
        mode = "light";
        source = "custom";
        custom_palette = colorScheme.default.name;
      };

      bar = {
        order = [
          "default"
          "island"
        ];

        default = {
          enabled = true;
          position = "top";
          layer = "overlay";
          smart_auto_hide = true;
          reserve_space = false;
          start = [
            "launcher"
            "workspaces"
          ];
          center = [ ];
          end = [
            "weather"
            "media"
            "volume"
            "brightness"
            "tray"
            "bluetooth"
            "network"
          ];
        };

        island = {
          enabled = true;
          position = "top";
          layer = "overlay";
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
            "clock-moscow"
          ];
          end = [ ];
        };
      };

      widget = {
        clock-current = {
          type = "clock";
          capsule = true;
          capsule_fill = "primary";
          capsule_foreground = "on_primary";
        };
        clock-moscow = {
          type = "clock";
          timezone = "Europe/Moscow";
          capsule = true;
          capsule_fill = "secondary";
          capsule_foreground = "on_secondary";
        };
      };

      location = {
        auto_locate = false;
        address = "Boracay, Philippines";
      };

      weather = {
        enabled = true;
        unit = "metric";
        refresh_minutes = 30;
        effects = true;
      };

      osd = {
        offset_y = 42; # 34px bar + 8px gap.
      };

      notification = {
        enable_daemon = true;
        position = "top_center";
        offset_y = 42; # 34px bar + 8px gap.
      };
    };
  };
}
