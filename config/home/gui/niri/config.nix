{
  colorScheme,
  ...
}:
let
  inherit (colorScheme.default) palette;
in
''
  include "active-profile.kdl"
  include "autoload.kdl"
  include "binds.kdl"
  include "private.kdl"
  include "windowrule.kdl"

  input {
    keyboard {
      xkb {
        layout "us, ru"
        options "grp:win_space_toggle"
      }
    }
  }

  layout {
    border {
      off
    }

    shadow {
      off
    }

    focus-ring {
      active-gradient from="${palette.aqua}" to="${palette.light_green}" angle=45 relative-to="workspace-view"
      urgent-gradient from="${palette.red}" to="${palette.light_orange}" angle=45 relative-to="workspace-view"
      inactive-color "${palette.white}"
    }
  }

  prefer-no-csd
''
