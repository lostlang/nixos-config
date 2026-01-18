{
  programs.nixvim.opts = {
    mouse = "a";
    termguicolors = true;
    clipboard = "unnamedplus";
    colorcolumn = [
      "80"
      "100"
    ];
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
    updatetime = 500;
  };
}
