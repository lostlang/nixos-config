{
  lib,
  ...
}:
{
  options.myConfig.cloudflare = {
    tunnels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
}
