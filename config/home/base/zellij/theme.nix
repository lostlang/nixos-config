{
  colorScheme,
  ...
}:
let
  inherit (colorScheme.default) palette;
in
{
  fg = palette.green;
  bg = palette.white;
  white = palette.black;
  red = palette.light_white;
  inherit (palette) orange;
  inherit (palette) yellow;
  inherit (palette) green;
  cyan = palette.aqua;
  inherit (palette) blue;
  magenta = palette.purple;
  black = palette.light_white;
}
