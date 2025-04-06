{ user, ... }:
{
  programs.hyprland.enable = true;
  programs.waybar.enable = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = user;
}
