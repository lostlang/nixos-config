{
  hostname,
  lib,
  pkgs,
  user,
  ...
}:
let
  ssh-wrapper = pkgs.callPackage ../../../../../script/ssh-wrapper {
    inherit hostname user;
  };
in
{
  home.packages = [ ssh-wrapper ];

  programs.zsh.initContent = ''
    ssh() {
      if [[ -o interactive ]]; then
        command ssh-wrapper "$@"
      else
        command ${lib.getExe pkgs.openssh} "$@"
      fi
    }

    (( $+functions[compdef] )) && compdef _ssh ssh
  '';
}
