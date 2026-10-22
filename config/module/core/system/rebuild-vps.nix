{
  config,
  lib,
  pkgs,
  pythonScriptEnv,
  user,
  ...
}:
let
  hosts = config.myConfig.ssh.vpsHosts;

  rebuild-vps = pkgs.writeShellApplication {
    name = "rebuild-vps";

    runtimeInputs = with pkgs; [
      fzf
      nixos-rebuild
      openssh
      pythonScriptEnv
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/rebuild-vps.py \
        --fzf-executable ${lib.getExe pkgs.fzf} \
        --nixos-rebuild-executable ${lib.getExe pkgs.nixos-rebuild} \
        --config-dir ${lib.escapeShellArg "/home/${user}/.config/nixos/config"} \
        ${
          lib.escapeShellArgs (
            lib.concatMap (host: [
              "--host"
              host
            ]) hosts
          )
        } \
        "$@"
    '';
  };
in
{
  environment.systemPackages = lib.mkIf (hosts != [ ]) [ rebuild-vps ];
}
