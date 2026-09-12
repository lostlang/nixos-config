{
  config,
  lib,
  user,
  ...
}:
let
  inherit (config.myConfig.ssh) hosts identities vpsHosts;
  allHosts = lib.unique (identities ++ hosts ++ vpsHosts);

  secretNames = map (name: "host.${name}") allHosts;

  hostsContent = lib.concatMapStringsSep "\n" (name: ''
    Host ${name}
      HostName ${config.sops.placeholder."host.${name}"}
    ${lib.optionalString (builtins.elem name identities) "  IdentityFile /home/${user}/.ssh/${name}_ed25519"}
    ${lib.optionalString (builtins.elem name vpsHosts) "  User ${user}"}
  '') allHosts;
in
{
  sops = {
    secrets = lib.genAttrs secretNames (_: { });
    templates."ssh/hosts.conf" = {
      owner = user;
      content = hostsContent;
    };
  };
}
