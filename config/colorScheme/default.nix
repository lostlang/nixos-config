let
  lostsand = {
    name = "lostsand";
    palette = import ./lostsand.nix;
  };
in
{
  default = lostsand;

  inherit lostsand;
}
