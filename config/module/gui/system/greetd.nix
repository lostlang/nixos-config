{
  colorScheme,
  config,
  lib,
  pkgs,
  user,
  ...
}:
{
  services.displayManager.noctalia-greeter = {
    enable = lib.mkDefault false;

    cursorTheme = {
      inherit (config.stylix.cursor) package name;
    };

    settings = {
      session.default = "Hyprland";

      user.default = user;

      idle.timeout = 60;

      appearance = {
        hide_logo = true;
        password_style = "random";
        scheme = "Synced";
        theme_mode = "light";
        font_family = config.stylix.fonts.monospace.name;
        palette = import ../home/noctalia/greeter-theme.nix { inherit colorScheme; };
      };
      cursor.size = config.stylix.cursor.size;
      keyboard = {
        layout = "us, ru";
        options = "grp:win_space_toggle";
      };
    };
  };

  services.greetd = lib.mkIf (!config.services.displayManager.noctalia-greeter.enable) {
    enable = true;

    settings = {
      default_session = {
        command = lib.getExe' pkgs.hyprland "start-hyprland";
        inherit user;
      };
    };
  };
}
