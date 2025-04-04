{
  programs.nixvim.plugins.lsp = {
    enable = true;

  };

  programs.nixvim.extraConfigLua = ''
    local notify = require("notify")
    local last_notify_id = nil

    vim.api.nvim_create_autocmd({"CursorHold"}, {
      pattern = "*",
      callback = function()
        local diagnostics = vim.diagnostic.get(0, {lnum = vim.api.nvim_win_get_cursor(0)[1] - 1})
        if #diagnostics > 0 then
          local severity = diagnostics[1].severity
          local level_map = {
            [vim.diagnostic.severity.ERROR] = { level = vim.log.levels.ERROR, title = "ERROR" },
            [vim.diagnostic.severity.WARN]  = { level = vim.log.levels.WARN, title = "WARN" },
            [vim.diagnostic.severity.INFO]  = { level = vim.log.levels.INFO, title = "INFO" },
            [vim.diagnostic.severity.HINT]  = { level = vim.log.levels.DEBUG, title = "HINT" },
          }
          last_notify_id = notify(diagnostics[1].message, level_map[severity].level or vim.log.levels.INFO, {title = level_map[severity].title, timeout = false })
        else
          if last_notify_id then
            notify.dismiss(last_notify_id)
            last_notify_id = nil
          end
        end
      end,
    })
  '';

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
