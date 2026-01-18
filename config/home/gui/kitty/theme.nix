{
  colorScheme,
  ...
}:
let
  palette = colorScheme.default.palette;
in
''
  background            ${palette.light_white}
  foreground            ${palette.black}
  cursor                ${palette.red}
  selection_background  ${palette.white}
  color0                ${palette.black}
  color8                ${palette.light_black}
  color1                ${palette.red}
  color9                ${palette.light_red}
  color2                ${palette.green}
  color10               ${palette.light_green}
  color3                ${palette.yellow}
  color11               ${palette.light_yellow}
  color4                ${palette.blue}
  color12               ${palette.light_blue}
  color5                ${palette.purple}
  color13               ${palette.light_purple}
  color6                ${palette.aqua}
  color14               ${palette.light_aqua}
  color7                ${palette.white}
  color15               ${palette.light_white}
  selection_foreground  ${palette.light_black}
''
