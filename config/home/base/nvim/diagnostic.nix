{
  programs.nixvim.diagnostic.settings = {
    virtual_text = false;

    signs = {
      text = {
        ERROR = "󰃤 ";
        WARN = " ";
        INFO = " ";
        HINT = "󱠂 ";
      };
    };
  };
}
