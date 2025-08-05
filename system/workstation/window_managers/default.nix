{ window_manager, user, ... }:
{
  imports = [ ./${window_manager}.nix ];

  services.xserver.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = user;
}
