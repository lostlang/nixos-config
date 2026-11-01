{
  config,
  lib,
  osConfig,
  pkgs,
  pythonScriptEnv,
  user,
  vpsHostnames,
  ...
}:
let
  sshTemplate = pkgs.writeText "openbao-ssh-hosts.template" (
    lib.concatStringsSep "\n" (
      lib.imap0 (index: host: /* sshconfig */ ''
        Host ${host}
          HostName ''${address_${toString index}}
          User ${user}
      '') vpsHostnames
    )
  );
  openbaoSshHosts = pkgs.writeShellApplication {
    name = "openbao-get-ssh-hosts";

    runtimeInputs = with pkgs; [
      coreutils
      pythonScriptEnv
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/openbao/render-template.py \
        --address "https://$(${lib.getExe' pkgs.coreutils "cat"} ${
          lib.escapeShellArg osConfig.sops.secrets."openbao.domain".path
        })" \
        --token "$(${lib.getExe' pkgs.coreutils "cat"} /run/openbao-client/token)" \
        --mount config \
        --template-file ${lib.escapeShellArg (toString sshTemplate)} \
        --output-file ${lib.escapeShellArg "${config.home.homeDirectory}/.ssh/openbao-hosts.conf"} \
        ${
          lib.escapeShellArgs (
            lib.concatLists (
              lib.imap0 (index: host: [
                "--secret"
                "address_${toString index}"
                "server/${host}"
                "server_ip"
              ]) vpsHostnames
            )
          )
        } \
        "$@"
    '';
  };
in
{
  options.programs.openbao-get-ssh-hosts.enable = lib.mkEnableOption "OpenBao SSH host configuration";

  config = lib.mkIf config.programs.openbao-get-ssh-hosts.enable {
    home.packages = [ openbaoSshHosts ];

    systemd.user.services.openbao-get-ssh-hosts = {
      Unit = {
        Description = "Generate SSH hosts from OpenBao";
        StartLimitIntervalSec = 0;
      };

      Service = {
        Type = "oneshot";
        ExecStartPre = "${lib.getExe' pkgs.systemd "systemctl"} --system is-active --quiet openbao-client-login.service";
        ExecStart = lib.getExe openbaoSshHosts;
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "5min";
      };
      Install.WantedBy = [ "default.target" ];
    };

    programs.ssh.includes = [ "~/.ssh/openbao-hosts.conf" ];
  };
}
