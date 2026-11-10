{
  imports = [
    ./commands

    ./aliases.nix
    ./completions.nix
  ];

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
