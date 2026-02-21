{
  pkgs,
  user,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    niri
  ];

  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "niri-session";
        user = user;
      };
    };
  };
}
