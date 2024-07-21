{ pkgs, ... }: {
programs.nixvim = {
	extraPlugins = with pkgs.vimPlugins; [
		comment-nvim
	];
	extraConfigLua = ''
require("Comment").setup()
'';
};
}
