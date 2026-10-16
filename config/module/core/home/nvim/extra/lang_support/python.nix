{
  programs.nixvim.plugins.lsp.servers.pyright = {
    enable = true;
    package = null;

    cmd = [
      "pyright-sandbox"
      "--stdio"
    ];

    extraOptions.before_init.__raw = /* lua */ ''
      function(params)
        params.processId = vim.NIL
      end
    '';
  };
}
