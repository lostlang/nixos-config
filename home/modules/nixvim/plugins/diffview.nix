{ pkgs, ... }: {
programs.nixvim = {
	extraPlugins = with pkgs.vimPlugins; [
		diffview-nvim
	];
	keymaps = [
		{
			mode = "n";
			key = "<C-o>";
			action = ":DiffviewOpen<CR>";
			options = {
				desc = "Diffview Open";
				silent = true;
			};
		}
		{
			mode = "n";
			key = "<C-k>";
			action = ":DiffviewClose<CR>";
			options = {
				desc = "Diffview Close";
				silent = true;
			};
		}
		{
			mode = "n";
			key = "<C-l>";
			action = ":DiffviewFileHistory<CR>";
			options = {
				desc = "Diffview File History";
				silent = true;
			};
		}
	];
};
}
