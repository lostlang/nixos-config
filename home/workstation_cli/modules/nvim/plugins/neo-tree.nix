{
	programs.nixvim.plugins.neo-tree = {
		enable = true;
		
		window.position = "float";
		defaultComponentConfigs.gitStatus.symbols = {
			untracked = "";
			unstaged = "";
			staged = "󰸞";
		};
	};

	programs.nixvim.keymaps = [
		{
			mode = "n";
			key = "<C-c>";
			action = ":Neotree toggle<CR>";
			options = {
				desc = "Toggle file tree";
				silent = true;
			};
		}
		{
			mode = "n";
			key = "<C-f>";
			action = ":Neotree reveal<CR>";
			options = {
				desc = "Open file tree with target on this file";
				silent = true;
			};
		}
	];
}
