{
  programs.nixvim.plugins.rainbow-delimiters = {
    enable = true;

    highlight = [
      "RainbowDelimiterRed"
      "RainbowDelimiterOrange"
      "RainbowDelimiterYellow"
      "RainbowDelimiterGreen"
      "RainbowDelimiterCyan"
      "RainbowDelimiterBlue"
      "RainbowDelimiterViolet"
    ];
  };
}
