{ ... }: {
programs.nixvim = {
	plugins = {
		luasnip.enable = true;
		cmp-nvim-lsp.enable = true;
		cmp-path.enable = true;
		cmp_luasnip.enable = true;
	};
	plugins.cmp = {
		enable = true;
		settings = {
			autoEnableSources = true;
			completion = { autocomplete = false; };
			experimental = { ghost_text = true; };
			performance = {
				debounce = 60;
				fetchingTimeout = 200;
				maxViewEntries = 30;
			};
			snippet = {
				expand = ''
function(args)
	require("luasnip").lsp_expand(args.body)
end
'';
			};
			formatting = {
				fields = [ "kind" "abbr" "menu" ];
				format = ''
function(entry, vim_item)
	local icons = {
		Text = "",
		Method = "",
		Function = "󰡱",
		Constructor = "",
		Field = "󰂡",
		Variable = "",
		Class = "󰠱",
		Interface = "",
		Module = "󰅱",
		Property = "󱈤",
		Unit = "",
		Value = "󰎠",
		Enum = "",
		Keyword = "󰌋",
		Snippet = "",
		Color = "",
		File = "󰈙",
		Reference = "",
		Folder = "",
		EnumMember = "",
		Constant = "󰐀",
		Struct = "",
		Event = "",
		Operator = "󰆖",
		TypeParameter = "󰅲",
		Copilot = "",
		Codeium = "",
	}

	local menus = {
		nvim_lsp = "[LSP]",
		buffer = "[Buffer]",
		luasnip = "[Snip]",
		nvim_lua = "[Lua]",
		treesitter = "[Treesitter]",
		path = "[Path]",
		nvim_lsp_signature_help = "[Signature]",
		copilot = "[AI]",
		codeium = "[AI]",
	}

	vim_item.menu = menus[entry.source.name]
	vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
	return vim_item
end
'';
			};
			sources = [
				{ name = "codeium"; }
				{ name = "nvim_lsp"; }
				{ name = "path"; }
				{ name = "luasnip"; }
			];
			window = {
				completion = { border = "solid"; };
				documentation = { border = "solid"; };
			};
			mapping = {
				"<C-k>" = "cmp.mapping.select_prev_item()";
				"<C-j>" = "cmp.mapping.select_next_item()";
				"<C-d>" = "cmp.mapping.scroll_docs(-4)";
				"<C-f>" = "cmp.mapping.scroll_docs(4)";
				"<C-Space>" = "cmp.mapping.complete()";
				"<C-e>" = "cmp.mapping.close()";
				"<CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true, })";
			};
		};
	};
};
}
