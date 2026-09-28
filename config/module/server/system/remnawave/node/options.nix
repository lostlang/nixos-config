{
  lib,
  ports,
  ...
}:
{
  options.services.remnawave-node = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    hopping.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    hopping.availableNodeCount = lib.mkOption {
      type = lib.types.ints.between 1 ports.remnawave.node.hopping.count;
      default = 1;
    };
  };
}
