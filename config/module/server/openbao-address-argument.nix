{
  config,
  lib,
  pkgs,
  ports,
}:
if config.services.openbao.enable then
  lib.escapeShellArg "http://127.0.0.1:${toString ports.openbao.api}"
else
  /* sh */ ''"https://$(${lib.getExe' pkgs.coreutils "cat"} ${
    lib.escapeShellArg config.sops.secrets."openbao.domain".path
  })"''
