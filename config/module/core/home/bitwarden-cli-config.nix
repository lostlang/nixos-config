{
  config,
  lib,
  osConfig,
  pkgs,
  pythonScriptEnv,
  ...
}:
let
  profiles = osConfig.myConfig.bitwardenCli.profiles;
  bw = lib.getExe pkgs.bitwarden-cli;
  completionCommands = lib.escapeShellArgs ([ "bw" ] ++ map (name: "bw-${name}") profiles);

  profileDirectory = name: "${config.xdg.configHome}/bw/${name}";
  profileSessionPath = name: "bw-${name}/session";

  profileWrappers = lib.mapAttrsToList (
    name: _:
    pkgs.writeShellApplication {
      name = "bw-${name}";

      runtimeInputs = [
        pkgs.bitwarden-cli
        pythonScriptEnv
      ];

      text = /* sh */ ''
        export BITWARDENCLI_APPDATA_DIR=${lib.escapeShellArg (profileDirectory name)}
        exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/bitwarden-cli-wrapper.py \
          --bw-executable ${lib.escapeShellArg bw} \
          --session-file "$XDG_RUNTIME_DIR/${profileSessionPath name}" \
          --command "$@"
      '';
    }
  ) (builtins.listToAttrs (map (name: lib.nameValuePair name true) profiles));
in
{
  config = {
    home.packages = profileWrappers;
    programs.zsh.initContent = ''
      eval "$(${bw} completion --shell zsh)"
      (( $+functions[compdef] )) && compdef _bw ${completionCommands}
    '';
  };
}
