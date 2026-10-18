{
  config,
  lib,
  pkgs,
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
      python3
    ];

    text = /* sh */ ''
      export PYTHONPATH=${../../../../script}''${PYTHONPATH:+:$PYTHONPATH}

      exec ${lib.getExe pkgs.python3} ${../../../../script/rebuild-vps.py} \
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
