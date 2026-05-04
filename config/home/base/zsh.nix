{
  secretPath,
  ...
}:
{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases =
      let
        flakeDir = "$HOME/.config/nixos/config/";
        secret = "${secretPath}/secret.yaml";
        key = "${secretPath}/key";
      in
      {
        rebuild-os = "sudo nixos-rebuild switch --flake ${flakeDir}";
        update-flake = ''nix flake update --flake "path:${flakeDir}"'';
        btop = "btop -p 1";
        v = "nvim .";
        ai = "zellij --layout=code";
        edit-secret = "sudo -E SOPS_AGE_KEY_FILE=${key} sops ${secret}";
        files-for-aichat-rag = ''git ls-files --cached --others --exclude-standard | sed "s|^|$(pwd)/|" | wl-copy'';
      };

    oh-my-zsh = {
      enable = true;
      plugins = [ "sudo" ];
      theme = "bira";
    };
  };
}
