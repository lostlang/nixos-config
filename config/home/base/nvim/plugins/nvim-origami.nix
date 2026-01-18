{
  programs.nixvim.opts = {
    foldlevel = 99;
    foldlevelstart = 99;
  };

  programs.nixvim.plugins.origami = {
    enable = true;

    settings = {
      foldtext = {
        diagnosticsCount = false;
        gitsignsCount = false;
      };
      autoFold.enabled = false;
    };
  };
}
