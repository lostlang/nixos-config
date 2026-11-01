{
  lib,
  pkgs,
}:
{
  name,
  package,
  configFile ? null,
  port,
}:
let
  prepareRoot = pkgs.writeShellScript "${name}-prepare-root" /* sh */ ''
    set -eu
    ${lib.getExe' pkgs.coreutils "cp"} -RL --no-preserve=mode ${package}/. "$RUNTIME_DIRECTORY/"
    ${lib.optionalString (configFile != null) /* sh */ ''
      ${lib.getExe' pkgs.coreutils "cp"} --remove-destination ${lib.escapeShellArg configFile} "$RUNTIME_DIRECTORY/config.json"
    ''}
  '';
in
{
  systemd.services.${name} = {
    description = "Static web server for ${name}";

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      RuntimeDirectory = name;
      ExecStartPre = prepareRoot;
      ExecStart = lib.escapeShellArgs [
        (lib.getExe pkgs.static-web-server)
        "--host"
        "127.0.0.1"
        "--port"
        (toString port)
        "--root"
        "/run/${name}"
        "--cache-control-headers=false"
      ];
      DynamicUser = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      Restart = "on-failure";
    };
  };
}
