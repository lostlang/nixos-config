{
  imports = [
    ./lang_support
    ./themes

    ./cmp.nix
    ./gen.nix
    ./inc-rename.nix
    ./indent-blankline.nix
    # ./lazygit.nix
    ./lsp.nix
    ./lualine.nix
    # ./minuet-ai.nix
    ./neo-tree.nix
    ./noice.nix
    ./none-ls.nix
    ./notify.nix
    ./rainbow-delimiters.nix
    ./smear-cursor.nix
    ./telescope.nix
    ./todo-comments.nix
    ./treesitter.nix
    ./twilight.nix
  ];

  programs.nixvim.plugins = {
    luasnip.enable = true;
    web-devicons.enable = true;

    codeium-nvim.enable = true;
    dropbar.enable = true;
    gitsigns.enable = true;
    highlight-colors.enable = true;
    illuminate.enable = true;
    neoscroll.enable = true;
    which-key.enable = true;
  };
}
