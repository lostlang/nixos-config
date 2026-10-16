{
  programs.nixvim.plugins.treesitter = {
    enable = true;

    indent.enable = true;
    highlight.enable = true;
    folding.enable = true;
  };

  programs.nixvim.extraConfigLuaPre = builtins.readFile ./comment-folds.lua;
}
