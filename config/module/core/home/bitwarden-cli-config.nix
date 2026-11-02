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
  profileDirectory = name: "${config.xdg.configHome}/bw/${name}";
  profileSessionPath = name: "bw-${name}/session";

  profileWrappers = map (
    name:
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
  ) (lib.unique profiles);
in
{
  config = {
    home.packages = profileWrappers;
  };
}
