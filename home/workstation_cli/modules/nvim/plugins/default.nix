{
  imports = [
    ./themes
    ./lang_support

    ./rainbow-delimiters.nix
    ./treesitter.nix
    ./indent-blankline.nix
    ./todo-comments.nix
    ./render-markdown.nix
    ./neo-tree.nix
    ./lualine.nix
    ./lazygit.nix
    ./telescope.nix
    ./cmp.nix
    ./lsp.nix
  ];

  programs.nixvim.plugins = {
    web-devicons.enable = true;
    luasnip.enable = true;

    illuminate.enable = true;
    markdown-preview.enable = true;
    gitsigns.enable = true;
    dropbar.enable = true;
    # barbecue.enable = true;
  };
}
