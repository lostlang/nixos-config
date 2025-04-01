{
  programs.nixvim.plugins.lsp.servers = {
    nixd.enable = true;
  };

  programs.nixvim.plugins.none-ls.sources.formatting = {
    nixfmt.enable = true;
  };
}
