{
  virtualisation.docker = {
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [
        "--all"
        "--filter=until=168h"
      ];
    };
  };
}
