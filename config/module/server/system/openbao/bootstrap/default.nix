{
  config,
  lib,
  pkgs,
  ports,
  pythonScriptEnv,
  vpsHostnames,
  ...
}:
let
  secretEngines = import ./secret-engine.nix {
    inherit lib vpsHostnames;
  };
  engineArgs = lib.concatMap (
    mount:
    let
      template = pkgs.writeText "openbao-${mount}-engine.json" (builtins.toJSON secretEngines.${mount});
    in
    [
      "--secret-engine"
      mount
      (toString template)
    ]
  ) (builtins.attrNames secretEngines);

  policies = import ./policies.nix {
    inherit lib pkgs;
    mounts = builtins.attrNames secretEngines;
  };
  policyArgs = [
    "--policy"
    "administrator"
    (toString policies.administratorPolicy)
    "--policy"
    "common-vault"
    (toString policies.commonPolicy)
  ]
  ++ lib.concatMap (host: [
    "--policy"
    "${host}-vault"
    (toString (policies.vaultPolicy host))
  ]) vpsHostnames;

  userArgs = [
    "--user"
    "administrator"
    "administrator"
    "--user"
    "common-vault"
    "common-vault"
  ]
  ++ lib.concatMap (host: [
    "--user"
    "${host}-vault"
    "${host}-vault"
  ]) vpsHostnames;

  bootstrap = pkgs.writeShellApplication {
    name = "openbao-bootstrap";

    runtimeInputs = [
      pythonScriptEnv
      config.services.openbao.package
    ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/openbao-bootstrap.py \
        --bao-executable ${lib.getExe' config.services.openbao.package "bao"} \
        --address http://127.0.0.1:${toString ports.openbao.api} \
        ${lib.escapeShellArgs engineArgs} \
        ${lib.escapeShellArgs policyArgs} \
        ${lib.escapeShellArgs userArgs} \
        "$@"
    '';
  };
in
{
  environment.systemPackages = lib.mkIf config.services.openbao.enable [ bootstrap ];
}
