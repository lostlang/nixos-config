{
  programs.nixvim.diagnostic.settings = {
    virtual_text = false;
    virtual_lines = true;

    signs = {
      text = {
        ERROR = " ";
        WARN = " ";
        INFO = " ";
        HINT = " ";
      };
    };
  };
}
