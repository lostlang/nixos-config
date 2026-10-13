{
  colorScheme,
  ...
}:
let
  inherit (colorScheme.default) palette;
in
/* lua */ ''
  hl.config({
    general = {
      col = {
        active_border = {
          colors = { "${palette.aqua}", "${palette.light_green}" },
          angle = 45,
        },
        inactive_border = "${palette.white}",
      },
    },
  })

  hl.window_rule({
    match = { tag = "urgent" },
    border_color = {
      colors = { "${palette.red}", "${palette.light_orange}" },
      angle = 45,
    },
  })

  hl.on("window.urgent", function(window)
    if window and window.mapped and not window.active then
      hl.dispatch(hl.dsp.window.tag({ window = window, tag = "+urgent" }))
    end
  end)

  hl.on("window.active", function(window)
    if window and window.mapped and window.active then
      hl.dispatch(hl.dsp.window.tag({ window = window, tag = "-urgent" }))
    end
  end)
''
