{ pkgs, ... }: {
programs.nixvim = {
	extraPlugins = with pkgs.vimPlugins; [
		gitsigns-nvim
	];
	extraConfigLua = ''require("gitsigns").setup({ })'';
};
}
