{
  programs.waybar = {
    enable = true;

    style = builtins.readFile ./style.css;
    settings.mainBar = {
      reload_style_on_change = true;
      layer = "top";
      position = "left";
      margin-top = 15;
      margin-bottom = 15;
      margin-left = 5;
      spacing = 5;
      modules-left = [
        "cpu"
        "memory"
        "network"
        "bluetooth"
        "pulseaudio"
        "power-profiles-daemon"
        "custom/power"
      ];
      modules-center = [
        "clock"
        "hyprland/language"
        "tray"
        "mpris"
      ];
      modules-right = [ "hyprland/workspaces" ];
      "hyprland/workspaces" = {
        disable-scroll = true;
        format = "{icon}";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          # "4" = " ";
          # "5" = " ";
          # "6" = " ";
          # "7" = " ";
          # "8" = " ";
          "9" = "󰠮";
          "10" = "";
          "default" = "󰊠";
        };
      };
      "hyprland/language" = {
        format = "{}";
        format-en = "🇬🇧 EN";
        format-ru = "🇷🇺 RU";
      };
      clock = {
        format = ''
          {:%a
          %H
          %M}'';
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          weeks-pos = "right";
          format = {
            "months" = "<span color='#437F06'>{}</span>";
            "weeks" = "<span color='#257DC7'>  W{}</span>";
            "weekdays" = "<span color='#257DC7'>{}</span>";
            "today" = "<span color='#257DC7'>{}</span>";
          };
        };
      };
      mpris = {
        interval = 1;
        format = "{status_icon} {artist} - {title}";
        title-len = 30;
        artist-len = 20;
        status-icons = {
          paused = "󰏤";
          playing = "󰐊";
          stopped = "󰓛";
        };
      };
      network = {
        tooltip = false;
        format-wifi = "󰖩 on";
        format-disconnected = "󰖪 off";
        format-ethernet = "󰈀 on";
        on-click = "nm-connection-editor";
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰖁  {volume}%";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        format-icons = {
          headphone = "󰋋";
          headset = "󰋎";
          phone = "";
          phone-muted = "";
          portable = "";
          car = "";
          default = [
            "  "
            "  "
          ];
        };
      };
      bluetooth = {
        format = "  {status}";
        format-off = "󰂲  {status}";
        format-connected = "󰂱  on";
        on-click = "blueman-manager";
      };
      memory = {
        format = ''
            R {percentage:02d}%
            S {swapPercentage:02d}%'';
      };
      cpu = {
        format = ''
            {usage}%
          󰓅  {avg_frequency:0.1f}'';
      };
      power-profiles-daemon = {
        format = "{icon}";
        tooltip = true;
        tooltip-format = ''
          Power profile: {profile}
          Driver: {driver}'';
        format-icons = {
          default = "";
          performance = "";
          balanced = "";
          power-saver = "";
        };
      };
      "custom/power" = {
        format = "";
        tooltip = false;
        on-click = "wlogout";
      };
      tray = {
        spacing = 5;
      };
    };
  };
}
