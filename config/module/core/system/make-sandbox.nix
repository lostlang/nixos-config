{
  lib,
  pkgs,
}:
{
  name,
  user,
  executable,
  sandboxDirectory ? null,
  runtimeInputs ? [ ],
  shareNetwork ? false,
  readOnlyProject ? false,
  showGit ? false,
  environment ? { },
  hostEnvPassthrough ? [ ],
  directories ? [ ],
  binds ? [ ],
  roBinds ? [ ],
}:
let
  arguments = [
    "--user"
    user
    "--bubblewrap-executable"
    (lib.getExe pkgs.bubblewrap)
    "--runtime-path"
    (lib.makeBinPath runtimeInputs)
  ]
  ++ lib.optionals (sandboxDirectory != null) [
    "--sandbox-directory"
    sandboxDirectory
  ]
  ++ lib.optional shareNetwork "--share-network"
  ++ lib.optional readOnlyProject "--read-only-project"
  ++ lib.optional showGit "--show-git"
  ++ lib.concatMap (name: [
    "--host-env-passthrough"
    name
  ]) hostEnvPassthrough
  ++ lib.concatMap (directory: [
    "--directory"
    directory
  ]) directories
  ++ lib.concatMap (mount: [
    "--bind"
    mount.source
    mount.target
  ]) binds
  ++ lib.concatMap (mount: [
    "--ro-bind"
    mount.source
    mount.target
  ]) roBinds
  ++ lib.concatLists (
    lib.mapAttrsToList (name: value: [
      "--setenv"
      name
      (toString value)
    ]) environment
  )
  ++ [
    "--command"
    executable
  ];
in
pkgs.writeShellScriptBin name /* sh */ ''
  export PYTHONPATH=${../../../../script}''${PYTHONPATH:+:$PYTHONPATH}

  exec ${lib.getExe pkgs.python3} ${../../../../script/make-sandbox.py} ${lib.escapeShellArgs arguments} "$@"
''
