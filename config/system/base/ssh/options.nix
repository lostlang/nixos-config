{
  lib,
  ...
}:
{
  options.myConfig.ssh.keys = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
}
