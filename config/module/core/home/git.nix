{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Alec Lang";
        email = "lostlang@icloud.com";
      };
      pull.rebase = true;
      rebase.autoStash = true;
    };

    ignores = [
      ".direnv"
      ".envrc"

      ".aider*"
      ".codex"

      "**/.venv/"
      "**/__pycache__/"
    ];
  };
}
