{
  programs.nixvim.plugins.lsp.servers.gopls = {
    enable = true;
    package = null;

    cmd = [ "gopls-sandbox" ];
  };
}
