{
  lib,
  ports,
  ...
}:
{
  services.sunshine = {
    enable = lib.mkDefault false;

    autoStart = true;
    capSysAdmin = true;

    settings = {
      capture = "wlr";
      port = ports.sunshine.start + 5;
    };
  };
}
