{ ... }: {
programs.nixvim = {
	plugins.neo-tree = {
		enable = true;
		enableGitStatus = true;
		enableDiagnostics = true;
		window = {
			mappings = {
				"o" = "open";
			};
		};
		defaultComponentConfigs = {
			gitStatus = {
				symbols = {
					untracked = "";
					unstaged = "";
					staged = "󰸞";
				};
			};
		};
	};
	keymaps = [
		{
			mode = "n";
			key = "<C-c>";
			action = ":Neotree toggle<CR>";
			options = {
				desc = "Toggle Neotree";
				silent = true;
			};
		}
		{
			mode = "n";
			key = "<C-f>";
			action = ":Neotree reveal<CR>";
			options = {
				desc = "Reveal file Neotree";
				silent = true;
			};
		}
	];
};
}
