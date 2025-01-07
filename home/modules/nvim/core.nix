{
  programs.nixvim.opts = {
    mouse = "a";
    clipboard = "unnamedplus";
    colorcolumn = "100";
    number = true;
    relativenumber = true;
    encoding = "utf-8";
    smartindent = true;
    spelllang = [
      "en_us"
      "ru"
    ];
    spell = true;
    list = true;
    listchars = {
      space = "•";
      tab = "▎-";
      eol = "↵";
    };
  };
}
