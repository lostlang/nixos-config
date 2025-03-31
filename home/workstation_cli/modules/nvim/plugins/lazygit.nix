{
  programs.nixvim.plugins.lazygit = {
    enable = true;
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<C-l>";
      action = ":LazyGit<CR>";
      options = {
        desc = "Open LazyGit";
        silent = true;
      };
    }
  ];
}
