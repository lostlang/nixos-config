{
  colorScheme,
  ...
}:
let
  inherit (colorScheme.default) palette;

  unselected = {
    base = palette.green;
    background = palette.light_white;
    emphasis_0 = palette.orange;
    emphasis_1 = palette.blue;
    emphasis_2 = palette.purple;
    emphasis_3 = palette.aqua;
  };

  selected = unselected // {
    base = palette.black;
    background = palette.white;
  };
in
{
  text_unselected = unselected;
  text_selected = selected;

  ribbon_unselected = unselected // {
    base = palette.light_white;
    background = palette.aqua;
    emphasis_0 = palette.white;
    emphasis_1 = palette.white;
    emphasis_2 = palette.white;
    emphasis_3 = palette.white;
  };
  ribbon_selected = selected // {
    base = palette.light_white;
    background = palette.green;
    emphasis_0 = palette.light_white;
    emphasis_1 = palette.light_white;
    emphasis_2 = palette.light_white;
    emphasis_3 = palette.light_white;
  };

  table_title = unselected // {
    base = palette.blue;
  };
  table_cell_unselected = unselected;
  table_cell_selected = selected;

  list_unselected = unselected;
  list_selected = selected;

  frame_unselected = unselected // {
    base = palette.black;
  };
  frame_selected = unselected;
  frame_highlight = unselected // {
    base = palette.blue;
  };

  exit_code_success = unselected;
  exit_code_error = unselected // {
    base = palette.red;
  };

  multiplayer_user_colors = {
    player_1 = palette.purple;
    player_2 = palette.blue;
    player_3 = palette.orange;
    player_4 = palette.yellow;
    player_5 = palette.aqua;
    player_6 = palette.green;
    player_7 = palette.red;
    player_8 = palette.light_blue;
    player_9 = palette.light_purple;
    player_10 = palette.light_aqua;
  };
}
