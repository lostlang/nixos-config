{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases =
      let
        flakeDir = "$HOME/.config/nixos/config/";
      in
      {
        rebuild-os = "sudo nixos-rebuild switch --impure --flake ${flakeDir}";
        update-flake = ''nix flake update --flake "path:${flakeDir}"'';
        btop = "btop -p 1";
        v = "nvim .";
        ai = "zellij --layout=code";
        files-for-aichat-rag = ''git ls-files --cached --others --exclude-standard | sed "s|^|$(pwd)/|" | wl-copy'';
      };

    oh-my-zsh = {
      enable = true;
      plugins = [ "sudo" ];
      theme = "bira";
    };
  };
}
