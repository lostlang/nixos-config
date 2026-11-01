{
  lib,
  mounts,
  pkgs,
}:
let
  accessibleMounts = builtins.filter (mount: mount != "secret") mounts;
  policyFile = name: paths: pkgs.writeText "openbao-${name}.json" (builtins.toJSON { path = paths; });
in
{
  administratorPolicy = policyFile "administrator" {
    "*".capabilities = [
      "create"
      "read"
      "update"
      "patch"
      "delete"
      "list"
      "scan"
      "sudo"
    ];
  };

  vaultPolicy =
    host:
    policyFile host (
      lib.foldl' (
        paths: mount:
        paths
        // {
          "${mount}/data/shared/*".capabilities = [ "read" ];
          "${mount}/data/server/${host}".capabilities = [
            "read"
            "update"
          ];
        }
      ) { } accessibleMounts
    );

  commonPolicy = policyFile "common-vault" (
    lib.foldl' (
      paths: mount:
      paths
      // {
        "${mount}/data/*".capabilities = [ "read" ];
        "${mount}/metadata".capabilities = [ "list" ];
        "${mount}/metadata/*".capabilities = [
          "read"
          "list"
        ];
      }
    ) { } accessibleMounts
  );
}
