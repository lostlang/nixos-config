{
  lib,
  ...
}:
{
  services.keyd = {
    enable = lib.mkDefault false;

    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        pause = "leftmeta";
        scrolllock = "leftalt";
        insert = "leftcontrol";
      };
    };
  };
}
