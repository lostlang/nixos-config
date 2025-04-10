{
  programs.nixvim.plugins.lsp.servers = {
    gopls.enable = true;
  };

  programs.nixvim.plugins.none-ls.sources.formatting = {
    gofumpt.enable = true;
    goimports_reviser.enable = true;
  };
}
