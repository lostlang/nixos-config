{
  colorScheme,
  ...
}:
let
  theme = (import ./theme.nix { inherit colorScheme; }).light;
in
{
  primary = theme.mPrimary;
  on_primary = theme.mOnPrimary;
  secondary = theme.mSecondary;
  on_secondary = theme.mOnSecondary;
  tertiary = theme.mTertiary;
  on_tertiary = theme.mOnTertiary;
  error = theme.mError;
  on_error = theme.mOnError;
  surface = theme.mSurface;
  on_surface = theme.mOnSurface;
  surface_variant = theme.mSurfaceVariant;
  on_surface_variant = theme.mOnSurfaceVariant;
  hover = theme.mHover;
  on_hover = theme.mOnHover;
  outline = theme.mOutline;
  shadow = theme.mShadow;
}
