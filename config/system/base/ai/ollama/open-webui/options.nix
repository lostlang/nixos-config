{
  lib,
  ...
}:
{
  options.myConfig.openWebui.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
}
