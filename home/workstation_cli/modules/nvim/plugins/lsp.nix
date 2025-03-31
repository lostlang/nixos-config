{
  programs.nixvim.plugins.lsp = {
    enable = true;
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "gD";
      action.__raw = "vim.lsp.buf.declaration";
      options = {
        desc = "Go to declaration";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "gd";
      action.__raw = "vim.lsp.buf.definition";
      options = {
        desc = "Go to definition";
        silent = true;
      };
    }
  ];
}
