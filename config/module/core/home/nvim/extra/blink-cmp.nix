{
  programs.nixvim.extraFiles."lua/completion/todo_words.lua".source = ./todo-words.lua;

  programs.nixvim.plugins.blink-cmp = {
    enable = true;

    settings = {
      sources = {
        default = [
          "snippets"
          "lsp"
          "path"
          "buffer"
          "todo_words"
        ];

        providers.todo_words = {
          name = "Todo words";
          module = "completion.todo_words";
          enabled.__raw = /* lua */ ''
            function()
              local cursor = vim.api.nvim_win_get_cursor(0)
              local before_cursor = vim.api.nvim_get_current_line():sub(1, cursor[2])
              return before_cursor:match("%.[%w_]*$") == nil
            end
          '';
        };
      };

      snippets.preset = "luasnip";

      keymap = {
        preset = "enter";
        "<Esc>" = [
          "cancel"
          "fallback"
        ];
        "<CR>" = [
          "select_and_accept"
          "fallback"
        ];
      };

      completion = {
        list.selection = {
          preselect = true;
          auto_insert = false;
        };
        documentation.auto_show = true;
      };

      cmdline = {
        enabled = true;
        keymap.preset = "cmdline";
      };
    };
  };
}
