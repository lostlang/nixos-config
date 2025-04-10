{
  programs.nixvim.plugins.indent-blankline = {
    enable = true;

    settings = {
      indent.highlight = [
        "IblRed"
        "IblOrange"
        "IblYellow"
        "IblGreen"
        "IblCyan"
        "IblBlue"
        "IblViolet"
      ];
      scope.enabled = false;
    };
  };
}
