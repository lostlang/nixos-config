{
  programs.nixvim.plugins.lualine = {
    enable = true;

    settings = {
      options = {
        component_separators = {
          left = "󰇙";
          right = "󰇙";
        };
        section_separators = {
          left = "";
          right = "";
        };
      };
      sections = {
        lualine_a = [ "mode" ];
        lualine_b = [
          {
            __unkeyed-1 = {
              __raw = ''
                function() return vim.bo.modified and "  UNSAVED " or "" end,
              '';
            };
          }
          "searchcount"
        ];
        lualine_c = [
          "diff"
          {
            __unkeyed-1 = "diagnostics";
            sources = [ "nvim_diagnostic" ];
            symbols = {
              error = "󰃤 ";
              warn = " ";
              info = " ";
              hint = "󱠂 ";
            };
          }
        ];
        lualine_x = [ "filetype" ];
        lualine_y = [ "encoding" ];
        lualine_z = [ "location" ];
      };
      inactive_sections = {
        lualine_a = [ ];
        lualine_b = [ ];
        lualine_c = [ "filename" ];
        lualine_x = [ ];
        lualine_y = [ ];
        lualine_z = [ ];
      };
    };
  };
}
