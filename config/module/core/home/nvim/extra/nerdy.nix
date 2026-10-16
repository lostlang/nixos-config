{
  programs.nixvim.plugins.nerdy = {
    enable = true;

    enableTelescope = true;
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>fn";
      action = ":Telescope nerdy<CR>";
      options = {
        desc = "Telescope find Nerd Font icon";
        silent = true;
      };
    }
  ];
}
