{
  programs.bat = {
    enable = true;

    config = {
      theme = "TwoDark";
    };
  };

  home.file.".config/bat/themes".source = ./themes;
}
