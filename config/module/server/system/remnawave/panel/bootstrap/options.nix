{
  lib,
  ...
}:
{
  options.services.remnawave-panel = {
    bootstrap.enable = lib.mkEnableOption "automatic Remnawave node bootstrap";

    nodes = {
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
  };
}
