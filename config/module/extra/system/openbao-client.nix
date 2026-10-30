{
  config,
  lib,
  pkgs,
  pythonScriptEnv,
  user,
  ...
}:
let
  openbaoClientLogin = pkgs.writeShellApplication {
    name = "openbao-client-login";

    runtimeInputs = with pkgs; [
      coreutils
      openbao
      pythonScriptEnv
    ];

    text = /* sh */ ''
      domain="$(cat ${lib.escapeShellArg config.sops.secrets."openbao.domain".path})"
      role_id="$(cat ${lib.escapeShellArg config.sops.secrets."openbao.role-id".path})"
      secret_id="$(cat ${lib.escapeShellArg config.sops.secrets."openbao.secret-id".path})"

      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/openbao/client-login.py \
        --address "https://$domain" \
        --role-id "$role_id" \
        --secret-id "$secret_id" \
        --output-file /run/openbao-client/token \
        --owner ${lib.escapeShellArg user} \
        "$@"
    '';
  };
in
{
  options.programs.openbao-client.enable = lib.mkEnableOption "OpenBao client";

  config = lib.mkIf config.programs.openbao-client.enable {
    sops.secrets = {
      "openbao.domain" = {
        key = "domain.openbao";
        owner = user;
      };
    }
    //
      lib.genAttrs
        [
          "openbao.role-id"
          "openbao.secret-id"
        ]
        (_: {
          owner = user;
        });

    systemd.services.openbao-client-login = {
      description = "Login to OpenBao";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      unitConfig.StartLimitIntervalSec = 0;

      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe openbaoClientLogin;
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "5min";
      };
    };

  };
}
