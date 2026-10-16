{
  imports = [
    ./lang_support
    ./themes

    ./diagnostic.nix
    ./indent-blankline.nix
    ./lualine.nix
    ./neo-tree.nix
    ./notify.nix
    ./rainbow-delimiters.nix
    ./telescope.nix
    ./todo-comments.nix
  ];

  programs.nixvim.plugins = {
    web-devicons.enable = true;

    dropbar.enable = true;
    gitsigns.enable = true;
    highlight-colors.enable = true;
    illuminate.enable = true;
    noice.enable = true;
    which-key.enable = true;
  };

  programs.nixvim.extraConfigLua = builtins.readFile ./clipboard.lua;
}
