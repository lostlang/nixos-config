{
  programs.nixvim.diagnostics = {
    virtual_text = false;
    signs = {
      text.__raw = ''
        {
          [vim.diagnostic.severity.ERROR] = "󰃤 ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = "󱠂 ",
        },
      '';
    };
  };
}
