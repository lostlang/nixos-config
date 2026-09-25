{
  programs.nixvim.opts = {
    mouse = "a";
    termguicolors = true;
    colorcolumn = [
      "80"
      "100"
    ];
    number = true;
    relativenumber = true;
    encoding = "utf-8";
    smartindent = true;
    spelllang = [
      "en_us"
      "ru"
    ];
    spell = true;
    list = true;
    listchars = {
      space = "•";
      tab = "▎-";
      eol = "↵";
    };
    updatetime = 500;
  };

  programs.nixvim.extraConfigLua = ''
    if vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil then
      vim.g.clipboard = "osc52"

      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          if vim.v.event.operator == "y" and vim.v.event.regname == "" then
            vim.fn.setreg(
              "+",
              vim.fn.getreg('"'),
              vim.fn.getregtype('"')
            )
          end
        end,
      })
    else
      vim.opt.clipboard = "unnamedplus"
    end
  '';
}
