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
      capture = "kms";
      port = ports.sunshine.start + 5;
    };
  };
}
