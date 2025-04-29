{
  wayland.windowManager.hyprland.settings = {
    # hyprctl clients
    windowrule = [
      "float, nm-connection-editor"
      "pin, nm-connection-editor"

      "float, blueman-manager-wrapped"
      "pin, blueman-manager-wrapped"

      "float, blueman-applet-wrapped"
      "pin, blueman-applet-wrapped"
      "move 1600 0, blueman-applet-wrapped"

      "float, title:^(Picture-in-Picture)"
      "pin, title:^(Picture-in-Picture)"
      "size 640 360, title:^(Picture-in-Picture)"
      "move 1280 0, title:^(Picture-in-Picture)"

      "workspace 3, librewolf"
      "workspace 9, obsidian"
      "workspace 10, org.telegram.desktop"
    ];
  };
}
