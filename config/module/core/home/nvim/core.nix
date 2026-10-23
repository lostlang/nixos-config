{
  programs.nixvim = {
    opts = {
      autoread = true;
      encoding = "utf-8";
      mouse = "a";
      termguicolors = true;
      smartindent = true;

      number = true;
      relativenumber = true;
      colorcolumn = [
        "80"
        "100"
      ];

      foldlevel = 99;
      foldlevelstart = 99;

      list = true;
      listchars = {
        eol = "↵";
        multispace = "•";
        tab = "▎-";
        trail = "•";
      };

      spell = true;
      spelllang = [
        "en_us"
        "ru"
      ];
    };

    autoCmd = [
      {
        event = [
          "FocusGained"
          "BufEnter"
          "CursorHold"
        ];
        command = "checktime";
      }
    ];

    extraConfigLuaPre = /* lua */ ''
      require("nvim.spellfile").config({ confirm = false })
    '';
  };
}
