{
  imports = [
    ./themes

    ./rainbow-delimiters.nix
    ./treesitter.nix
    ./indent-blankline.nix
    ./todo-comments.nix
    ./render-markdown.nix
    ./neo-tree.nix
    ./diagnostic.nix
    ./lualine.nix
  ];

  programs.nixvim.plugins = {
    web-devicons.enable = true;

    illuminate.enable = true;
    barbecue.enable = true;
    lazygit.enable = true;
  };
}
