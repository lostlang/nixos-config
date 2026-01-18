{
  programs.nixvim.plugins.indent-blankline = {
    enable = true;

    settings = {
      indent.highlight = [
        "IblRed"
        "IblOrange"
        "IblGreen"
        "IblCyan"
        "IblBlue"
        "IblViolet"
      ];
      scope.enabled = false;
    };
  };
}
