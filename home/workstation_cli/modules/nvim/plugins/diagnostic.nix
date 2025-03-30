{
  programs.nixvim.diagnostics = {
    virtual_text = false;
    signs = {
      text = {
        DiagnosticSignError = "󰃤 ";
        DiagnosticSignWarn = " ";
        DiagnosticSignHint = "󱠂 ";
        DiagnosticSignInfo = " ";
      };
    };
  };
}
