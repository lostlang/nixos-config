let
  lostsand = {
    name = "lostsand";
    palette = import ./lostsand.nix;
  };
in
{
  default = lostsand;

  lostsand = lostsand;
}
