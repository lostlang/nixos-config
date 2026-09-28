{
  lib,
  ports,
  ...
}:
{
  services.syncthing = {
    enable = lib.mkDefault false;

    guiAddress = "0.0.0.0:${toString ports.syncthing.gui}";
  };
}
