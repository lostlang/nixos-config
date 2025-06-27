{
  wayland.windowManager.hyprland.settings = {
    # hyprctl clients
    windowrule = [
      "float, class:nm-connection-editor"
      "pin, class:nm-connection-editor"

      "float, class:blueman-manager-wrapped"
      "pin, class:blueman-manager-wrapped"

      "float, class:blueman-applet-wrapped"
      "pin, class:blueman-applet-wrapped"
      "move 1600 0, class:blueman-applet-wrapped"

      "float, title:^(Picture-in-Picture)"
      "pin, title:^(Picture-in-Picture)"
      "size 640 360, title:^(Picture-in-Picture)"
      "move 1280 0, title:^(Picture-in-Picture)"

      "workspace 3, class:librewolf"
      "workspace 9, class:obsidian"
      "workspace 10, class:org.telegram.desktop"
    ];
  };
}
