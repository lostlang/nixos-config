{
  hostname,
  lib,
  pkgs,
  user,
  ...
}:
let
  ssh-multiplex-wrapper = pkgs.callPackage ../../../../../script/ssh-multiplex-wrapper {
    inherit hostname user;
  };
in
{
  home.packages = [ ssh-multiplex-wrapper ];

  programs.zsh.initContent = ''
    ssh() {
      if [[ -o interactive ]]; then
        command ssh-multiplex-wrapper "$@"
      else
        command ${lib.getExe pkgs.openssh} "$@"
      fi
    }

    (( $+functions[compdef] )) && compdef _ssh ssh
  '';
}
