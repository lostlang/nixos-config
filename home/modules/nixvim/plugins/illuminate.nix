{ pkgs, ... }: {
programs.nixvim = {
	extraPlugins = with pkgs.vimPlugins; [
		vim-illuminate
	];
};
}
