{
  lib,
  ...
}:
{
  options.services.remnawave-panel.nodes = {
    basic = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      apply = lib.unique;
    };

    hopping = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      apply = lib.unique;
    };
  };
}
