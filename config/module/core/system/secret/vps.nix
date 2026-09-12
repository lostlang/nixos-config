{
  config,
  lib,
  hostname,
  ...
}:
let
  inherit (config.myConfig.vps) keys;

  mkSecret = name: {
    name = "vps.${name}.ip";
    value = { };
  };
in
{
  options.myConfig.vps.keys = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config = lib.mkMerge [
    (lib.mkIf (lib.hasPrefix "vps" hostname) {
      sops.secrets."vps.${hostname}.ip" = { };
    })

    {
      sops.secrets = builtins.listToAttrs (map mkSecret keys);
    }
  ];
}
