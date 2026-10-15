{
  config,
  lib,
  pkgs,
  ...
}:
let
  python = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);

  shelfPython = pkgs.stdenvNoCC.mkDerivation {
    name = "noctalia-shelf-python";

    dontUnpack = true;

    nativeBuildInputs = with pkgs; [
      gobject-introspection
      wrapGAppsHook4
    ];
    buildInputs = with pkgs; [
      gtk4
      gtk4-layer-shell
    ];

    installPhase = /* sh */ ''
      makeWrapper ${lib.getExe python} "$out/bin/shelf-python" \
        --set SHELF_NO_LAYER_SHELL 1
    '';
  };
in
{
  home.packages = with pkgs; [
    glib
  ];

  # HACK: change borders and swap icon
  home.activation.shelfWindow = lib.hm.dag.entryAfter [ "writeBoundary" ] /* sh */ ''
    helper=${lib.escapeShellArg "${config.xdg.stateHome}/noctalia/plugins/materialized/community/shelf/helper/shelf-window.py"}
    if [ -f "$helper" ]; then
      run ${lib.getExe pkgs.gnused} -i \
        -e '/^\.shelf-card {{$/,/^}}$/{ s/^  border: .*;/  border: none;/; s/^  border-radius: .*;/  border-radius: 0;/; }' \
        -e 's/Gtk.Button(icon_name="edit-delete-symbolic", valign=Gtk.Align.CENTER)/Gtk.Button(label="󰩺", valign=Gtk.Align.CENTER)/' \
        -e 's/remove = Gtk.Button(icon_name="window-close-symbolic", valign=Gtk.Align.CENTER)/remove = Gtk.Button(label="󰩺", valign=Gtk.Align.CENTER)/' \
        "$helper"
    fi
  '';

  programs.noctalia.settings = {
    plugins.enabled = [ "alok-debnath/shelf" ];
    plugin_settings."alok-debnath/shelf".python = "${shelfPython}/bin/shelf-python";
  };
}
