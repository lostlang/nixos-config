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
  ];

	programs.nixvim.plugins = {
		web-devicons.enable = true;

		illuminate.enable = true;
	};
}
