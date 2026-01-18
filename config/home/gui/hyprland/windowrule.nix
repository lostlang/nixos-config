{
  wayland.windowManager.hyprland.settings = {
    # hyprctl clients
    windowrule = [
      "match:class nm-connection-editor, float on, pin on"

      "match:class blueman-applet-wrapped, float on, pin on, move 800 0"

      "match:title ^(Picture-in-Picture), float on, pin on, size 320 180, move 940 20"

      "match:class ^(imv)$, float on, pin on, size 300 300"

      "match:class librewolf, workspace 3"
      "match:class obsidian, workspace 9"
      "match:class org.telegram.desktop, workspace 10"
    ];
  };
}
