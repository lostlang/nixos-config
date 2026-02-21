{
  programs.nixvim.plugins.baleia = {
    enable = true;
  };

  programs.nixvim.extraConfigLua = ''
    local baleia = require("baleia").setup({})

    vim.api.nvim_create_user_command("BaleiaColorize", function()
      baleia.once(vim.api.nvim_get_current_buf())
    end, {})

    vim.api.nvim_create_autocmd("StdinReadPost", {
      callback = function()
        baleia.once(vim.api.nvim_get_current_buf())
      end,
    })

    vim.api.nvim_create_autocmd("BufReadPost", {
      pattern = { "*.log", "*.ansi", "*.out" },
      callback = function()
        baleia.once(vim.api.nvim_get_current_buf())
      end,
    })
  '';
}
