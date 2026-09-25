{
  lib,
  ...
}:
{
  services.syncthing = {
    enable = lib.mkDefault false;

    guiAddress = "0.0.0.0:8384";
  };
}
