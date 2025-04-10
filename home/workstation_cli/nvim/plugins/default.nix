{
  imports = [
    ./themes
    ./lang_support

    ./rainbow-delimiters.nix
    ./treesitter.nix
    ./indent-blankline.nix
    ./todo-comments.nix
    ./neo-tree.nix
    ./lualine.nix
    ./lazygit.nix
    ./telescope.nix
    ./cmp.nix
    ./lsp.nix
    ./smear-cursor.nix
    ./twilight.nix
    ./none-ls.nix
    # ./minuet-ai.nix
    ./gen.nix
    ./noice.nix
    ./inc-rename.nix
    ./notify.nix
  ];

  programs.nixvim.plugins = {
    web-devicons.enable = true;
    luasnip.enable = true;

    illuminate.enable = true;
    neoscroll.enable = true;
    which-key.enable = true;
    highlight-colors.enable = true;
    gitsigns.enable = true;
    dropbar.enable = true;
    codeium-nvim.enable = true;
  };
}
