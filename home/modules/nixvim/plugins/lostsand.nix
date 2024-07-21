{ pkgs, ... }: {
programs.nixvim = {
	extraPlugins = with pkgs.vimUtils; [
		(buildVimPlugin {
			pname = "lostsand.nvim";
			version = "2024-04-36";
			src = pkgs.fetchFromGitHub {
				owner = "lostlang";
				repo = "lostsand.nvim";
				rev = "f8b8c94f965e927bb8bd7f3c19dc02cd88df2254";
				hash = "sha256-mm44W9h2JJgTkB2r6PgF8kpcauFMD6fPaQo+Uj2ZRP8=";
			};
		})
	];
};
}
