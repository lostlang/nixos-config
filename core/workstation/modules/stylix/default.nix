{
  lib,
  ...
}:
{
  stylix = {
    enable = true;

    polarity = "light";

    base16Scheme = ./lostsand.yaml;

    homeManagerIntegration.autoImport = true;
  };
}
