{
  services.keyd = {
    enable = false;

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
