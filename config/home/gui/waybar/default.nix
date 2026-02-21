{
  colorScheme,
  ...
}:
let
  palette = colorScheme.default.palette;
  style = import ./theme.nix { inherit colorScheme; };
in
{
  stylix.targets.waybar.enable = false;

  programs.waybar = {
    enable = true;

    style = style;

    settings.mainBar = {
      reload_style_on_change = true;

      layer = "top";
      position = "left";
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
        "niri/language"
        "tray"
        "mpris"
      ];
      modules-right = [
        "niri/workspaces"
      ];
      "niri/workspaces" = {
        disable-scroll = true;
      };
      "niri/language" = {
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
            "months" = "<span color='${palette.green}'>{}</span>";
            "weeks" = "<span color='${palette.blue}'>  W{}</span>";
            "weekdays" = "<span color='${palette.blue}'>{}</span>";
            "today" = "<span color='${palette.blue}'>{}</span>";
          };
        };
      };
      mpris = {
        interval = 1;
        format = "{status_icon} {artist} - {title}";
        title-len = 30;
        artist-len = 20;
        status-icons = {
          paused = "󰏤 ";
          playing = "󰐊 ";
          stopped = "󰓛 ";
        };
      };
      network = {
        tooltip = false;
        format-wifi = "󰖩  on";
        format-disconnected = "󰖪  off";
        format-ethernet = "󰈀  on";
        on-click = "nm-connection-editor";
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰖁  {volume}%";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        format-icons = {
          headphone = "󰋋 ";
          headset = "󰋎 ";
          phone = " ";
          phone-muted = " ";
          portable = " ";
          car = " ";
          default = [
            " "
            " "
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
          default = " ";
          performance = " ";
          balanced = " ";
          power-saver = " ";
        };
      };
      "custom/power" = {
        format = " ";
        tooltip = false;
        on-click = "wlogout";
      };
      tray = {
        spacing = 5;
      };
    };
  };
}
