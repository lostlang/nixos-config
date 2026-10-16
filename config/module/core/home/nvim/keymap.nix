{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader.__raw = ''vim.keycode("<BS>")'';
    };

    keymaps = [
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "<localleader>";
        action = "<leader>";
        options.remap = true;
      }

      {
        mode = "x";
        key = "<leader>s";
        action = ":SmartSort<CR>";
        options = {
          desc = "Sort selected elements with Treesitter";
          silent = true;
        };
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>y";
        action = ":CopyLineContext<CR>";
        options = {
          desc = "Copy line context for LLM";
          silent = true;
        };
      }
      {
        mode = "v";
        key = "<Tab>";
        action = ">gv";
        options = {
          desc = "Increase indent and reselect";
          silent = true;
        };
      }
      {
        mode = "v";
        key = "<S-Tab>";
        action = "<gv";
        options = {
          desc = "Decrease indent and reselect";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<C-s>";
        action = ":w<CR>";
        options = {
          desc = "Safe file";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<C-a>";
        action = "ggVG";
        options = {
          desc = "Select all file";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader><SPACE>";
        action = ":nohlsearch<CR>";
        options = {
          desc = "Clear search highlighting";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<CR>";
        action = "za";
        options = {
          desc = "Toggle current fold";
          silent = true;
        };
      }
    ];
  };
}
