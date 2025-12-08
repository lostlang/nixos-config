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
      "move 800 0, class:blueman-applet-wrapped"

      "float, title:^(Picture-in-Picture)"
      "pin, title:^(Picture-in-Picture)"
      "size 320 180, title:^(Picture-in-Picture)"
      "noborder, title:^(Picture-in-Picture)"
      "move 940 20, title:^(Picture-in-Picture)"

      "float, class:^(imv)$"
      "pin, class:^(imv)$"
      "noborder, class:^(imv)$"
      "size 300 300, class:^(imv)$"

      "workspace 3, class:librewolf"
      "workspace 9, class:obsidian"
      "workspace 10, class:org.telegram.desktop"
    ];
  };
}
