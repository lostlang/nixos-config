{
  config,
  lib,
  pkgs,
  ...
}:
let
  remoteTimezone = "Europe/Moscow";
in
{
  # HACK: additions timezone for timezone-hub
  home.file."${config.xdg.stateHome}/noctalia/plugins/data/ahmedhossamdev/timezone-hub/data.json".text =
    builtins.toJSON {
      comparisons = [
        {
          tz = remoteTimezone;
        }
      ];
    };

  # HACK: change style timezone-hub
  home.activation.timezoneHubTypography = lib.hm.dag.entryAfter [ "writeBoundary" ] /* sh */ ''
    panel=${lib.escapeShellArg "${config.xdg.stateHome}/noctalia/plugins/materialized/community/timezone-hub/panel.luau"}
    if [ -f "$panel" ]; then
      run ${lib.getExe pkgs.gnused} -i -E \
        -e '/ui\.label\(\{ text = row\.label,/d' \
        -e 's/fontWeight = [^,}]+,?[ \t]*//g' \
        -e 's/fontSize = [^,}]+/fontWeight = "bold", fontSize = 12/g' \
        -e '/^    table\.insert\(parts, noctalia\.tr\($/,/^    \)\)$/d' \
        -e '/^      ui\.row\(\{ gap = 2, justify = "start" \}, \{$/,/glyph = "close"/{ /^        ui\.button\(\{$/,/^        \}\),$/d; }' \
        -e '/^local function rowActions\(/,/^end$/{ /^  if not isDeviceRow then$/,/^  end$/d; }' \
        "$panel"
    fi
  '';

  programs.noctalia.settings = {
    plugins.enabled = [
      "ahmedhossamdev/timezone-hub"
    ];

    plugin_settings."ahmedhossamdev/timezone-hub".panel_open_near_click = false;

    widget = {
      clock-current = {
        type = "clock";
        capsule = true;
        capsule_fill = "primary";
        capsule_foreground = "on_primary";
      };
      clock-remote = {
        type = "clock";
        capsule = true;
        capsule_fill = "secondary";
        capsule_foreground = "on_secondary";

        timezone = remoteTimezone;
        actions.left = "panel-toggle ahmedhossamdev/timezone-hub:panel";
      };
    };
  };
}
