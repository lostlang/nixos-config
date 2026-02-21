{
  lib,
  ...
}:
{
  imports = [
    ./script
  ];

  xdg.configFile."niri/resolution".source = ./resolution;

  xdg.configFile."niri/autoload.kdl".source = ./autoload.kdl;
  xdg.configFile."niri/binds.kdl".source = ./binds.kdl;
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
  xdg.configFile."niri/windowrule.kdl".source = ./windowrule.kdl;

  home.activation.niriSymlink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sf "$HOME/.config/niri/resolution/monitor_16_9_1920_1080.kdl" \
      "$HOME/.config/niri/active-profile.kdl"
  '';
}
