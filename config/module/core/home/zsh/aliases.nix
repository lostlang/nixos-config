{
  secretPath,
  ...
}:
{
  programs.zsh.shellAliases =
    let
      secret = "${secretPath}/secret.yaml";
      key = "${secretPath}/key";
    in
    {
      codex2 = ''CODEX_HOME="$HOME/.codex-second" codex'';
      edit-secret = "sudo -E SOPS_AGE_KEY_FILE=${key} sops ${secret}";
      gshallow = "git clone --depth 1";
      # files-for-aichat-rag = ''git ls-files --cached --others --exclude-standard | sed "s|^|$(pwd)/|" | wl-copy'';
      rebuild-os = "sudo nixos-rebuild switch --flake $HOME/.config/nixos/config/";
      v = "nvim .";
    };
}
