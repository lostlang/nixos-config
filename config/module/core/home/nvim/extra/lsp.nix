{
  programs.nixvim.plugins.lsp = {
    enable = true;
    inlayHints = true;

    capabilities = /* lua */ ''
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
    '';
  };
}
