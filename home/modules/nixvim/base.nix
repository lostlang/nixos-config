{ ... }: {
programs.nixvim = {
	opts = {
		mouse = "a";
		clipboard = "unnamedplus";
		colorcolumn = "100";
		number = true;
		relativenumber = true;
		encoding = "utf-8";
		smartindent = true;
		spelllang = [
			"en_us"
			"ru"
		];
		spell = true;
		list = true;
		listchars = {
			space = "•";
			tab = "▎-";
			eol = "↵";
		};
	};
	colorscheme = "lostsand";
	keymaps = [
		{
			mode = "v";
			key = "<Tab>";
			action = ">gv";
			options = {
				# desc = "Next tab";
				silent = true;
			};
		}
		{
			mode = "v";
			key = "<S-Tab>";
			action = "<gv";
			options = {
				# desc = "Next tab";
				silent = true;
			};
		}
		{
			mode = "n";
			key = "<C-s>";
			action = ":w<CR>";
			options = {
				desc = "Safe file";
				silent = true;
			};
		}
		{
			mode = "n";
			key = "<C-a>";
			action = "ggVG";
			options = {
				desc = "Salect all file";
				silent = true;
			};
		}
	];
	extraConfigLua = ''
local diagnostic_signs = {
	{ name = "DiagnosticSignError", text = "" },
	{ name = "DiagnosticSignWarn", text = "" },
	{ name = "DiagnosticSignHint", text = "󱠂" },
	{ name = "DiagnosticSignInfo", text = "" },
}

for _, sign in ipairs(diagnostic_signs) do
	vim.fn.sign_define(sign.name, {
		texthl = sign.name,
		text = sign.text,
		numhl = sign.name,
	})
end
'';
};
}
