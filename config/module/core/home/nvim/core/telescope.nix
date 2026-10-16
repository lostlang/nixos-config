{
  programs.nixvim.plugins = {
    telescope = {
      enable = true;

      settings = {
        defaults.__raw = /* lua */ ''
          require("telescope.themes").get_dropdown({
            preview = { filesize_limit = 0.5 },
            cache_picker = { num_pickers = 10 },
          })
        '';

        pickers.builtin.include_extensions = true;
      };

      extensions.fzf-native = {
        enable = true;

        settings = {
          case_mode = "ignore_case";
        };
      };
    };

    which-key = {
      settings.spec = [
        {
          __unkeyed-1 = "<leader>f";
          group = "Telescope finds";
        }
      ];
    };
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>fp";
      action = ":Telescope pickers<CR>";
      options = {
        desc = "Telescope picker history";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fr";
      action = ":Telescope resume<CR>";
      options = {
        desc = "Telescope resume last search";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = ":Telescope find_files<CR>";
      options = {
        desc = "Telescope find file";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = ":Telescope live_grep<CR>";
      options = {
        desc = "Telescope live grep";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fk";
      action = ":Telescope keymaps<CR>";
      options = {
        desc = "Telescope find keymap";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = ":Telescope buffers initial_mode=normal sort_lastused=true sort_mru=true<CR>";
      options = {
        desc = "Telescope find buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = ":Telescope highlights<CR>";
      options = {
        desc = "Telescope find highlight";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>ft";
      action = ":TodoTelescope<CR>";
      options = {
        desc = "Telescope find todos";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fs";
      action = ":Telescope spell_suggest<CR>";
      options = {
        desc = "Telescope find spell suggest";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fc";
      action = ":Telescope current_buffer_fuzzy_find<CR>";
      options = {
        desc = "Telescope live grep in current buffer";
        silent = true;
      };
    }
  ];
}
