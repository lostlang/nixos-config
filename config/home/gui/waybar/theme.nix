{
  colorScheme,
  ...
}:
let
  palette = colorScheme.default.palette;
in
''
  * {
    font-family: JetBrainsMono Nerd Fonts;
    font-size: 16px;
    box-shadow: none;
    text-shadow: none;
    border: none;
  }

  window#waybar>box {
    padding:10px;
  }

  window#waybar {
    background-color: alpha(${palette.white}, .8);
    color: ${palette.black};
  }

  window#waybar.hidden {
  	opacity: 0.2;
  }

  tooltip {
    background-color: ${palette.white};
    border-radius: 5px;
    padding: 10px;
  }

  tooltip label {
    color: ${palette.black};
  }

  #workspaces button {
    background: transparent;
    color: ${palette.blue};
    border-radius: 0;
    border: transparent;
    border-left: 3px solid transparent;
    border-right: 3px solid transparent;
  }

  #workspaces button.active {
    color: ${palette.green};
    border-right: 3px solid ${palette.green};
  }

  #workspaces button:hover:not(.active) {
    color: ${palette.green};
    border: transparent;
    border-left: 3px solid transparent;
    border-right: 3px solid ${palette.green};
  }
''
