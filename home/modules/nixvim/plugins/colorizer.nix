{ pkgs, ... }: {
programs.nixvim = {
	extraPlugins = with pkgs.vimPlugins; [
		nvim-colorizer-lua
	];
	extraConfigLua = ''
require("colorizer").setup()
'';
};
}
