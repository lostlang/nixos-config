{
  config,
  lib,
  user,
  ...
}:
let
  profiles = config.myConfig.bitwardenCli.profiles;

  secretName = profile: key: "bitwarden.${profile}.${key}";

  profileSecrets = lib.concatMap (
    profile:
    map
      (key: {
        name = secretName profile key;
        value = {
          owner = user;
        };
      })
      [
        "serverUrl"
        "clientId"
        "clientSecret"
        "masterPassword"
      ]
  ) profiles;
  profileTemplates = map (
    profile:
    lib.nameValuePair "bitwarden.${profile}.env" {
      owner = user;
      content = ''
        BW_SERVER_URL=${config.sops.placeholder.${secretName profile "serverUrl"}}
        BW_CLIENTID=${config.sops.placeholder.${secretName profile "clientId"}}
        BW_CLIENTSECRET=${config.sops.placeholder.${secretName profile "clientSecret"}}
      '';
    }
  ) profiles;
in
{
  options.myConfig.bitwardenCli.profiles = lib.mkOption {
    default = [ ];
    type = lib.types.listOf lib.types.str;
  };

  config = lib.mkIf (profiles != [ ]) {
    sops.secrets = builtins.listToAttrs profileSecrets;
    sops.templates = builtins.listToAttrs profileTemplates;
  };
}
