{ pkgs, ... }: {
nixpkgs.config = {
	allowUnfree = true;
};
programs.nixvim = {
	extraPlugins = with pkgs.vimPlugins; [
		codeium-nvim
	];
	extraConfigLua = ''
require("codeium").setup()
'';
};
}
