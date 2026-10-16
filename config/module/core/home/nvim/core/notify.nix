{
  programs.nixvim.plugins.notify = {
    enable = true;

    settings = {
      fps = 60;
      icons = {
        debug = " ";
        error = " ";
        info = " ";
        trace = " ";
        warn = " ";
      };
      level = "debug";
      max_width = 80;
      minimum_width = 50;
    };
  };
}
