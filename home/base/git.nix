{
  programs.git = {
    enable = true;

    settings.user = {
      name = "Alec Lang";
      email = "lostlang@icloud.com";
    };

    ignores = [
      ".envrc"
      ".direnv"
    ];
  };
}
