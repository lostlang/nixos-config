{
  programs.nixvim.plugins.rainbow-delimiters = {
    enable = true;

    settings.highlight = [
      "RainbowDelimiterRed"
      "RainbowDelimiterOrange"
      "RainbowDelimiterGreen"
      "RainbowDelimiterCyan"
      "RainbowDelimiterBlue"
      "RainbowDelimiterViolet"
    ];
  };
}
