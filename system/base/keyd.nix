{
  services.keyd = {
    enable = true;

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
