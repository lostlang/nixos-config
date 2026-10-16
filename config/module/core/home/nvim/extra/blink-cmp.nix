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
