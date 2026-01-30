{
  programs.nixvim.extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "nix",
      callback = function()
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.expandtab = true
      end,
    })
  '';

  programs.nixvim.plugins.lsp.servers.nixd = {
    enable = true;
  };
}
