{
  lib,
  ...
}:
{
  options.services.remnawave-panel = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
}
