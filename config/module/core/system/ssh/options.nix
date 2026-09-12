{
  lib,
  ...
}:
{
  options.myConfig.ssh = {
    identities = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    hosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    vpsHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
}
