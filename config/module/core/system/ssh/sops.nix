{
  config,
  lib,
  user,
  ...
}:
let
  inherit (config.myConfig.ssh) hosts identities;
  allHosts = lib.unique (identities ++ hosts);

  secretNames = map (name: "host.${name}") allHosts;

  hostsContent = lib.concatMapStringsSep "\n" (name: ''
    Host ${name}
      HostName ${config.sops.placeholder."host.${name}"}
    ${lib.optionalString (builtins.elem name identities) "  IdentityFile /home/${user}/.ssh/${name}_ed25519"}
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
