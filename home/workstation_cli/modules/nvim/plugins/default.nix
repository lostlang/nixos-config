{
  imports = [
    ./themes

    ./rainbow-delimiters.nix
    ./treesitter.nix
    ./indent-blankline.nix
    ./todo-comments.nix
    ./render-markdown.nix
    ./neo-tree.nix
    ./lualine.nix
    ./lazygit.nix
    ./telescope.nix
  ];

  programs.nixvim.plugins = {
    web-devicons.enable = true;

    illuminate.enable = true;
    gitsigns.enable = true;
    barbecue.enable = true;
  };
}
