{
  colorScheme,
  ...
}:
{
  programs.nixvim.plugins.smear-cursor = {
    enable = true;

    settings.cursor_color = "${colorScheme.default.palette.light_orange}";
  };
}
