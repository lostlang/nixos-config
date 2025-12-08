{
  programs.nixvim.extraConfigLua = ''
    local function diff_is_open()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_option(win, "diff") then
          return true
        end
      end
      return false
    end

    local function close_diff()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_option(win, "diff") then
          vim.api.nvim_win_call(win, function()
            vim.cmd("diffoff!")
          end)
        end
      end

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if name == "" then
          vim.api.nvim_win_close(win, true)
        end
      end
    end

    vim.api.nvim_create_user_command("DiffOpen", function()
      if diff_is_open() then
        return
      end

      local ft = vim.bo.filetype
      vim.cmd("vert new")
      vim.cmd("read ++edit #")
      vim.cmd("0d_")
      vim.bo.swapfile = false
      vim.bo.bufhidden = "wipe"
      vim.bo.filetype = ft
      vim.bo.readonly = true
      vim.bo.modifiable = false
      vim.bo.modified = false
      vim.cmd("diffthis")
      vim.cmd("wincmd p")
      vim.cmd("diffthis")
    end, {})

    vim.api.nvim_create_user_command("DiffClose", function()
      close_diff()
    end, {})

    vim.api.nvim_create_user_command("DiffToggle", function()
      if diff_is_open() then
        close_diff()
      else
        vim.cmd("DiffOpen")
      end
    end, {})
  '';
}
