{ pkgs, ... }: {
programs.nixvim = {
	extraPlugins = with pkgs.vimPlugins; [
		todo-comments-nvim
	];
	extraConfigLua = ''require("todo-comments").setup({ })'';
};
}
