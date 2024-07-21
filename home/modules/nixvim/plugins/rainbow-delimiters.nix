{ pkgs, ... }: {
programs.nixvim = {
	extraPlugins = with pkgs.vimPlugins; [
		rainbow-delimiters-nvim
	];
	extraConfigLua = ''
require("rainbow-delimiters.setup").setup({
	highlight = {
		"RainbowDelimiterRed",
		"RainbowDelimiterOrange",
		"RainbowDelimiterYellow",
		"RainbowDelimiterGreen",
		"RainbowDelimiterCyan",
		"RainbowDelimiterBlue",
		"RainbowDelimiterViolet",
	},
})
'';
};
}
