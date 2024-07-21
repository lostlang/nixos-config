{ pkgs, ... }: {
programs.nixvim = {
	plugins.lsp = {
		enable = true;
	};
	extraPlugins = with pkgs.vimPlugins; [
		lsp-status-nvim
	];
	extraConfigLua = ''
require('lsp-status').register_progress()
require('lsp-status').config({
	status_symbol = "",
})
'';
	keymaps = [
		{
			mode = [ "n" ];
			key = "gD";
			action = "<cmd>lua vim.lsp.buf.declaration()<cr>";
			options = {
				silent = true;
				desc = "[G]o to [D]eclaration";
			};
		}
		{
			mode = [ "n" ];
			key = "gd";
			action = "<cmd>lua vim.lsp.buf.definition()<cr>";
			options = {
				silent = true;
				desc = "[G]o to [d]efinition";
			};
		}
		{
			mode = [ "n" ];
			key = "gr";
			action = "<cmd>lua vim.lsp.buf.rename()<cr>";
			options = {
				silent = true;
				desc = "[G]o to [r]ename";
			};
		}
	];
};
}
