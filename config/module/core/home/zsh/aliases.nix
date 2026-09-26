{
  secretPath,
  ...
}:
{
  programs.zsh.shellAliases =
    let
      flakeDir = "$HOME/.config/nixos/config/";
      secret = "${secretPath}/secret.yaml";
      key = "${secretPath}/key";
    in
    {
      # ai = "zellij --layout=code";
      edit-secret = "sudo -E SOPS_AGE_KEY_FILE=${key} sops ${secret}";
      # files-for-aichat-rag = ''git ls-files --cached --others --exclude-standard | sed "s|^|$(pwd)/|" | wl-copy'';
      rebuild-os = "sudo nixos-rebuild switch --flake ${flakeDir}";
      update-flake = "nix flake update --flake ${flakeDir}";
      v = "nvim .";
    };
}
