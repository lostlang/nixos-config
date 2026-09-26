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
      python3
    ];

    text = ''
      export PYTHONPATH=${./..}''${PYTHONPATH:+:$PYTHONPATH}

      exec ${lib.getExe pkgs.python3} ${./main.py} \
        --config-dir /home/${user}/.config/nixos/config \
        --hosts ${lib.escapeShellArgs hosts}
    '';
  };
in
{
  environment.systemPackages = lib.mkIf (hosts != [ ]) [ rebuild-vps ];
}
