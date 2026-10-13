{
  colorScheme,
  ...
}:
let
  inherit (colorScheme.default) palette;

  lightPalette = {
    mPrimary = palette.green;
    mOnPrimary = palette.light_white;
    mSecondary = palette.blue;
    mOnSecondary = palette.light_white;
    mTertiary = palette.aqua;
    mOnTertiary = palette.light_white;

    mError = palette.red;
    mOnError = palette.light_white;

    mSurface = palette.light_white;
    mOnSurface = palette.black;
    mSurfaceVariant = palette.gradient.dark.g0;
    mOnSurfaceVariant = palette.black;
    mHover = palette.white;
    mOnHover = palette.black;

    mOutline = palette.green;
    mShadow = palette.gradient.dark.g4;

    terminal = {
      background = palette.light_white;
      foreground = palette.black;

      selectionBg = palette.white;
      selectionFg = palette.light_black;

      cursor = palette.light_orange;
      cursorText = palette.black;

      normal = {
        inherit (palette) black;
        inherit (palette) red;
        inherit (palette) green;
        inherit (palette) yellow;
        inherit (palette) blue;
        magenta = palette.purple;
        cyan = palette.aqua;
        inherit (palette) white;
      };
      bright = {
        black = palette.light_black;
        red = palette.light_red;
        green = palette.light_green;
        yellow = palette.light_yellow;
        blue = palette.light_blue;
        magenta = palette.light_purple;
        cyan = palette.light_aqua;
        white = palette.light_white;
      };
    };
  };
in
{
  dark = lightPalette;
  light = lightPalette;
}
