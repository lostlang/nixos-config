{
  hostname,
  lib,
  pkgs,
  pythonScriptEnv,
  user,
  ...
}:
let
  session-name = "ssh-${user}-${hostname}";
  ssh-multiplex-wrapper = pkgs.writeShellApplication {
    name = "ssh-multiplex-wrapper";

    runtimeInputs = with pkgs; [
      openssh
      pythonScriptEnv
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "ssh-multiplex-wrapper.py"} \
        --ssh-executable ${lib.getExe pkgs.openssh} \
        --session-name ${lib.escapeShellArg session-name} \
        "$@"
    '';
  };
in
{
  home.packages = [ ssh-multiplex-wrapper ];

  programs.zsh.initContent = /* sh */ ''
    ssh() {
      local -x TERM=xterm-256color

      if [[ -o interactive ]]; then
        command ssh-multiplex-wrapper "$@"
      else
        command ${lib.getExe pkgs.openssh} "$@"
      fi
    }
  '';
}
