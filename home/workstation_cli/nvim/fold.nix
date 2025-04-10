{
  programs.nixvim.opts = {
    foldlevel = 99;
    foldmethod = "indent";
  };

  programs.nixvim.extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function(args)
        local bufnr = args.buf
        local has_parser = pcall(vim.treesitter.get_parser, bufnr)
        if has_parser then
          vim.api.nvim_buf_set_option(bufnr, "foldmethod", "expr")
          vim.api.nvim_buf_set_option(bufnr, "foldexpr", "nvim_treesitter#foldexpr()")
        end
      end,
    })
  '';
}
