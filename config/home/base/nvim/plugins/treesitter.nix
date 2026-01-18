{
  pkgs,
  ...
}:
{
  programs.nixvim.plugins.treesitter = {
    enable = true;

    grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
    settings = {
      indent.enable = true;
      highlight = {
        enable = true;
        disable = ''
          function(lang, buf)
            local filename = vim.api.nvim_buf_get_name(buf)
            local ext = filename:match("^.+(%..+)$")
            local disabled_exts = { [".mod"] = true }
            return disabled_exts[ext] or false
          end
        '';
      };
    };
  };
}
