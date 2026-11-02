{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  profiles = osConfig.myConfig.bitwardenCli.profiles;
  bitwardenCommands = lib.escapeShellArgs (
    [ "bw" ] ++ map (name: "bw-${name}") (lib.unique profiles)
  );
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
  programs.zsh.initContent = lib.mkOrder 1000 /* sh */ ''
    source ${completions}
    source ${pkgs.bitwarden-cli}/share/zsh/site-functions/_bw
    (( $+functions[compdef] )) && compdef _bw ${bitwardenCommands}
    (( $+functions[compdef] )) && compdef _ssh ssh
  '';
}
