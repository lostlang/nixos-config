{ ... }: {
programs.nixvim = {
	plugins.lsp.servers.somesass_ls = {
		enable = true;
	};
};
}
