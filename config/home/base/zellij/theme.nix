{
  colorScheme,
  ...
}:
let
  palette = colorScheme.default.palette;
in
{
  fg = palette.green;
  bg = palette.white;
  white = palette.black;
  red = palette.light_white;
  orange = palette.orange;
  yellow = palette.yellow;
  green = palette.green;
  cyan = palette.aqua;
  blue = palette.blue;
  magenta = palette.purple;
  black = palette.light_white;
}
