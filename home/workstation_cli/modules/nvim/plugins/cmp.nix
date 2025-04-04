{
  programs.nixvim.plugins = {
    cmp-nvim-lsp.enable = true;
    cmp-path.enable = true;
    cmp-buffer.enable = true;
    cmp_luasnip.enable = true;
    cmp-cmdline.enable = true;
  };

  programs.nixvim.plugins.cmp = {
    enable = true;

    settings = {
      sources = [
        { name = "minuet"; }
        { name = "nvim_lsp"; }
        { name = "path"; }
        { name = "luasnip"; }
        { name = "buffer"; }
      ];
      snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
      formatting.format.__raw = ''
        function(entry, vim_item)
          local kind_icons = {
            Text = "",
            Method = "",
            Function = "󰡱",
            Constructor = "",
            Field = "󰂡",
            Variable = "",
            Class = "󰠱",
            Interface = "",
            Module = "󰅱",
            Property = "󱈤",
            Unit = "",
            Value = "󰎠",
            Enum = "",
            Keyword = "󰌋",
            Snippet = "",
            Color = "",
            File = "󰈙",
            Reference = "",
            Folder = "",
            EnumMember = "",
            Constant = "󰐀",
            Struct = "",
            Event = "",
            Operator = "󰆖",
            TypeParameter = "󰅲",
            Codeium = "",
            Ollama = "",
          }

          local menus = {
            cmdline = "[Cmd]";
            nvim_lsp = "[LSP]",
            buffer = "[Buffer]",
            luasnip = "[Snip]",
            nvim_lua = "[Lua]",
            treesitter = "[Treesitter]",
            path = "[Path]",
            nvim_lsp_signature_help = "[Signature]",
            codeium = "[AI]",
            cmp_ai = "[AI]",
            minuet = "[AI]",
          }

          vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
          vim_item.menu = menus[entry.source.name]
          return vim_item
        end,
      '';
      mapping = {
        "<UP>" = "cmp.mapping.select_prev_item()";
        "<DOWN>" = "cmp.mapping.select_next_item()";
        "<ESC>" = "cmp.mapping.abort()";
        "<CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
      };
    };
    cmdline = {
      "/" = {
        mapping = {
          __raw = "cmp.mapping.preset.cmdline()";
        };
        sources = [ { name = "buffer"; } ];
      };
      ":" = {
        mapping = {
          __raw = "cmp.mapping.preset.cmdline()";
        };
        sources = [
          { name = "path"; }
          {
            name = "cmdline";
            option = {
              ignore_cmds = [
                "Man"
                "!"
              ];
            };
          }
        ];
      };
    };
  };
}
