{
  programs.nixvim.plugins.inc-rename.enable = true;

  programs.nixvim.keymaps = [
    {
      mode = [
        "n"
        "v"
      ];
      key = "gR";
      action = ":IncRename ";
      options = {
        desc = "Lsp rename";
        silent = true;
      };
    }
  ];
}
