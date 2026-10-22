{
  lib,
  pkgs,
  pythonScriptEnv,
}:
{
  name,
  user,
  executable,
  sandboxDirectory ? null,
  runtimeInputs ? [ ],
  libInputs ? [ ],
  terminfo ? null,
  sslCertFile ? null,
  sslCertDir ? null,
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
  make-sandbox = pkgs.callPackage ./make-sandbox.nix {
    inherit pythonScriptEnv;
  };
  arguments = [
    "--user"
    user
    "--runtime-path"
    (lib.makeBinPath runtimeInputs)
    "--terminfo"
    terminfo
    "--library-path"
    (lib.makeLibraryPath libInputs)
    "--pkg-config-path"
    (lib.makeSearchPath "lib/pkgconfig" libInputs)
    "--ssl-cert-file"
    sslCertFile
    "--ssl-cert-dir"
    sslCertDir
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
  ++ lib.concatMap (name: [
    "--setenv"
    name
    (toString environment.${name})
  ]) (builtins.attrNames environment)
  ++ [ executable ];
in
pkgs.writeShellApplication {
  inherit name;

  runtimeInputs = [ make-sandbox ];

  text = /* sh */ ''
    exec make-sandbox ${lib.escapeShellArgs arguments} "$@"
  '';
}
