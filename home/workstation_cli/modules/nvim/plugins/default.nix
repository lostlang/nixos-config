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
    ./smear-cursor.nix
    ./twilight.nix
    ./none-ls.nix
  ];

  programs.nixvim.plugins = {
    web-devicons.enable = true;
    luasnip.enable = true;
    notify.enable = true;

    illuminate.enable = true;
    neoscroll.enable = true;
    noice.enable = true;
    markdown-preview.enable = true;
    gitsigns.enable = true;
    dropbar.enable = true;
  };
}
