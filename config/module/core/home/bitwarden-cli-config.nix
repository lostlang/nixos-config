{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  profiles = osConfig.myConfig.bitwardenCli.profiles;
  bw = lib.getExe pkgs.bitwarden-cli;
  completionCommands = lib.escapeShellArgs ([ "bw" ] ++ map (name: "bw-${name}") profiles);

  profileDirectory = name: "${config.xdg.configHome}/bw/${name}";
  profileEnvironmentPath = name: osConfig.sops.templates."bitwarden.${name}.env".path;
  profilePasswordPath = name: osConfig.sops.secrets."bitwarden.${name}.masterPassword".path;
  profileSessionPath = name: "bw-${name}/session";

  profileWrappers = lib.mapAttrsToList (
    name: _:
    pkgs.writeShellScriptBin "bw-${name}" ''
      export BITWARDENCLI_APPDATA_DIR=${lib.escapeShellArg (profileDirectory name)}
      exec ${pkgs.python3}/bin/python ${../../../script/bitwarden-cli-wrapper.py} \
        --bw-executable ${lib.escapeShellArg bw} \
        --session-file "$XDG_RUNTIME_DIR/${profileSessionPath name}" \
        -- "$@"
    ''
  ) (builtins.listToAttrs (map (name: lib.nameValuePair name true) profiles));

  profileServices = lib.mapAttrs' (
    name: _:
    lib.nameValuePair "bitwarden-cli-config-${name}" {
      Service = {
        Type = "oneshot";
        Environment = [ "BITWARDENCLI_APPDATA_DIR=${profileDirectory name}" ];
        EnvironmentFile = [
          (profileEnvironmentPath name)
        ];
        ExecStartPre = [
          "${bw} logout"
          "${pkgs.coreutils}/bin/mkdir -p ${profileDirectory name}"
        ];
        ExecStart = [
          "${bw} config server $BW_SERVER_URL"
          "${bw} login --apikey"
          ''
            ${lib.getExe pkgs.python3} ${../../../script/bitwarden-cli-unlock.py} \
              --bw-executable ${lib.escapeShellArg bw} \
              --password-file ${lib.escapeShellArg (profilePasswordPath name)} \
              --session-file %t/${profileSessionPath name}
          ''
        ];
      };

      Install.WantedBy = [ "default.target" ];
    }
  ) (builtins.listToAttrs (map (name: lib.nameValuePair name true) profiles));
in
{
  config = {
    home.packages = profileWrappers;
    systemd.user.services = profileServices;
    programs.zsh.initContent = ''
      eval "$(${bw} completion --shell zsh)"
      (( $+functions[compdef] )) && compdef _bw ${completionCommands}
    '';
  };
}
