{
  lib,
  ...
}:
{
  options.myConfig.zerotierone = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    interfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
}
