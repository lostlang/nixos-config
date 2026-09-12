{
  config,
  lib,
  pkgs,
  remnawave,
  ...
}:
let
  panelCfg = config.services.remnawave-panel;
  nodes = panelCfg.nodes.basic ++ panelCfg.nodes.hopping;
  bootstrapEnvFile = config.sops.templates."remnawave-node-bootstrap.env".path;
  nodeDomainsFile = config.sops.templates."remnawave-node-domains.json".path;
  bootstrapScript = pkgs.writeText "remnawave-node-bootstrap.py" (builtins.readFile ./bootstrap.py);
  python = pkgs.python3.withPackages (pythonPackages: [
    pythonPackages.cryptography
    pythonPackages.pip
  ]);
  bootstrapSetup = pkgs.writeShellScript "remnawave-node-bootstrap-setup" ''
    venv="$STATE_DIRECTORY/venv"

    if [ ! -x "$venv/bin/python" ]; then
      ${python}/bin/python3 -m venv --system-site-packages "$venv"
    fi

    if ! "$venv/bin/python" -c 'import importlib.metadata as m; raise SystemExit(m.version("remnawave-api") != "3.2.2")' 2>/dev/null; then
      "$venv/bin/pip" install --disable-pip-version-check --no-cache-dir "remnawave-api==3.2.2"
    fi
  '';
in
{
  imports = [
    ./options.nix
    ./sops.nix
  ];

  systemd.services.remnawave-node-bootstrap = lib.mkIf (panelCfg.enable && nodes != [ ]) {
    wantedBy = [ "multi-user.target" ];
    requires = [ "remnawave-panel.service" ];
    after = [
      "network-online.target"
      "remnawave-panel.service"
    ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "remnawave-node-bootstrap";
      EnvironmentFile = bootstrapEnvFile;
      Environment = [
        "API_PORT=${toString remnawave.panel.port}"
        "NODES_FILE=${nodeDomainsFile}"
        "MASK_PORT=${toString remnawave.mask.entryPoint.port}"
      ];
      ExecStartPre = bootstrapSetup;
      ExecStart = "/var/lib/remnawave-node-bootstrap/venv/bin/python ${bootstrapScript}";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 10;
      TimeoutStartSec = 180;
    };
  };
}
