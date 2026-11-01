{
  pkgs,
  ...
}:
let
  completions = pkgs.runCommand "python-argcomplete.zsh" { } /* sh */ ''
    ${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete --shell zsh \
      env-init \
      fmt-staged \
      hypr-resolution-switch \
      minecraft-data-copy \
      update-flake \
      make-sandbox \
      rebuild-vps \
      openbao-bootstrap \
      vaultwarden-bootstrap \
      openbao-client-login \
      openbao-get-ssh-hosts \
      system-clean \
      zp \
      zs \
    > "$out"
  '';
in
{
  programs.zsh.initContent = /* sh */ ''
    source ${completions}
  '';
}
