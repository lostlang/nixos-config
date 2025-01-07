{
  programs.nixvim.keymaps = [
    {
      mode = "v";
      key = "<Tab>";
      action = ">gv";
      options = {
        desc = "Increase indent and reselect";
        silent = true;
      };
    }
    {
      mode = "v";
      key = "<S-Tab>";
      action = "<gv";
      options = {
        desc = "Decrease indent and reselect";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<C-s>";
      action = ":w<CR>";
      options = {
        desc = "Safe file";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<C-a>";
      action = "ggVG";
      options = {
        desc = "Salect all file";
        silent = true;
      };
    }
  ];
}
