{
  config,
  lib,
  user,
  ...
}:
let
  keys = config.myConfig.ssh.keys;

  mkSecret = name: [
    {
      name = "ssh.${name}.host";
      value = {
        owner = user;
      };
    }
  ];
  secretEntries = builtins.concatMap mkSecret keys;

  hostsContent = lib.concatMapStringsSep "\n" (name: ''
    Host ${config.sops.placeholder."ssh.${name}.host"}
      IdentityFile /home/${user}/.ssh/${name}_ed25519
  '') keys;
in
{
  sops = {
    secrets = builtins.listToAttrs secretEntries;
    templates."ssh/hosts.conf" = {
      owner = user;
      content = hostsContent;
    };
  };
}
