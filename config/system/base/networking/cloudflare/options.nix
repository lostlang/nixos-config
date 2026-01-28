{
  lib,
  ...
}:
{
  options.myConfig.cloudflare = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    tunnels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
}
