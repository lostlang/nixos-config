{
  config,
  lib,
  pkgs,
  pythonScriptEnv,
  hostname,
  ...
}:
let
  bootstrap = pkgs.writeShellApplication {
    name = "vaultwarden-bootstrap";

    runtimeInputs = [ pythonScriptEnv ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/openbao/generate-secret.py \
        --secret secret ${lib.escapeShellArg "vaultwarden/${hostname}"} admin_token \
        --hash-secret config ${lib.escapeShellArg "server/${hostname}"} vaultwarden_admin_token \
        "$@"
    '';
  };
in
{
  environment.systemPackages = lib.mkIf config.services.vaultwarden.enable [ bootstrap ];
}
