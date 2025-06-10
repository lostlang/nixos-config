{
  programs.nixvim.plugins.rainbow-delimiters = {
    enable = true;

    highlight = [
      "RainbowDelimiterRed"
      "RainbowDelimiterOrange"
      "RainbowDelimiterGreen"
      "RainbowDelimiterCyan"
      "RainbowDelimiterBlue"
      "RainbowDelimiterViolet"
    ];
  };
}
