{
  programs.nixvim.plugins.twilight = {
    enable = true;
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<C-z>";
      action = ":Twilight<CR>";
      options = {
        desc = "Toggle twilight mode";
        silent = true;
      };
    }
  ];
}
