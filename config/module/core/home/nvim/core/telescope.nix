{
  programs.nixvim.plugins.telescope = {
    enable = true;

    extensions.fzf-native = {
      enable = true;

      settings = {
        case_mode = "ignore_case";
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "ff";
      action = ":Telescope find_files<CR>";
      options = {
        desc = "Telescope find file";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "fg";
      action = ":Telescope live_grep<CR>";
      options = {
        desc = "Telescope live grep";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "fk";
      action = ":Telescope keymaps<CR>";
      options = {
        desc = "Telescope find keymap";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "fb";
      action.__raw = ''
        function()
          local builtin = require('telescope.builtin')
          local action_state = require('telescope.actions.state')
          builtin.buffers({
            initial_mode = "normal",
            attach_mappings = function(prompt_bufnr, map)
              local delete_buf = function()
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                current_picker:delete_selection(function(selection)
                  vim.api.nvim_buf_delete(selection.bufnr, { force = true })
                end)
              end

              map('n', '<c-d>', delete_buf)

              return true
            end
          }, {
            sort_lastused = true,
            sort_mru = true,
            theme = "dropdown"
          })
        end
      '';
      options = {
        desc = "Telescope find buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "fh";
      action = ":Telescope highlights<CR>";
      options = {
        desc = "Telescope find highlight";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "ft";
      action = ":TodoTelescope<CR>";
      options = {
        desc = "Telescope find todos";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "fs";
      action = ":Telescope spell_suggest<CR>";
      options = {
        desc = "Telescope find spell suggest";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "fc";
      action = ":Telescope current_buffer_fuzzy_find<CR>";
      options = {
        desc = "Telescope live grep in current buffer";
        silent = true;
      };
    }
  ];
}
