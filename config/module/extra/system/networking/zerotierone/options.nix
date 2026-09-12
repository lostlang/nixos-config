{
  lib,
  ...
}:
{
  options.myConfig.zerotierone = {
    interfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
}
