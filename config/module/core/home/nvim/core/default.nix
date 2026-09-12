{
  imports = [
    ./themes

    ./indent-blankline.nix
    ./lualine.nix
    ./neo-tree.nix
    ./noice.nix
    ./notify.nix
    ./nvim-origami.nix
    ./rainbow-delimiters.nix
    ./smear-cursor.nix
    ./telescope.nix
    ./todo-comments.nix
  ];

  programs.nixvim.plugins = {
    luasnip.enable = true;
    web-devicons.enable = true;

    dropbar.enable = true;
    gitsigns.enable = true;
    highlight-colors.enable = true;
    illuminate.enable = true;
    neoscroll.enable = true;
    which-key.enable = true;
  };
}
