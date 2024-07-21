{pkgs, ...}: {
programs.nixvim = {
	extraPlugins = with pkgs.vimPlugins; [
		rainbow-delimiters-nvim
	];
	plugins.treesitter = {
		enable = true;
		indent = true;
		folding = false;
		nixvimInjections = true;
		grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
	};
};
}
