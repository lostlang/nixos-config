{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases =
      let
        flakeDir = "$HOME/.config/nixos/";
      in
      {
        rebuild-home = "home-manager switch --impure --flake ${flakeDir}";
        rebuild-os = "sudo nixos-rebuild switch --impure --flake ${flakeDir}";
        update-flake = ''nix flake update --impure --flake "path:${flakeDir}"'';
        btop = "btop -p 1";
        v = "zellij --layout=code";
        nix-shell = "nix-shell --run $SHELL";
      };

    oh-my-zsh = {
      enable = true;
      plugins = [ "sudo" ];
      theme = "bira";
    };
  };
}
