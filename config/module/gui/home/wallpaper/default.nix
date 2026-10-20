{
  config,
  lib,
  pkgs,
  pythonScriptEnv,
  colorScheme,
  ...
}:
let
  activeWallpaper = "${config.home.homeDirectory}/Pictures/Wallpapers";
  wallpaper = pkgs.callPackage ./page.nix { inherit colorScheme; };
  resolutionDirectory = ../hyprland/resolution;
  profiles =
    map
      (
        file:
        let
          values = lib.splitString "\"" (builtins.readFile (resolutionDirectory + "/${file}"));
          modes = builtins.filter (value: builtins.match "[0-9]+x[0-9]+@[0-9.]+" value != null) values;
        in
        {
          name = lib.removeSuffix ".lua" file;
          resolution = builtins.head (lib.splitString "@" (builtins.head modes));
        }
      )
      (
        builtins.filter (lib.hasSuffix ".lua") (builtins.attrNames (builtins.readDir resolutionDirectory))
      );

  resolutions = lib.unique (map (profile: profile.resolution) profiles);
  resolutionArgs = lib.concatMap (resolution: [
    "--resolution"
    resolution
  ]) resolutions;

  generated =
    pkgs.runCommand "generated-wallpapers"
      {
        nativeBuildInputs = with pkgs; [
          librewolf
        ];
      }
      /* sh */ ''
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv}/scripts/nix-wallpapers.py \
          --librewolf-executable ${lib.getExe pkgs.librewolf} \
          --render-html ${lib.escapeShellArg "${wallpaper}/index.html"} \
          ${lib.escapeShellArgs resolutionArgs} \
          --count 10 \
          --render-scale 2 \
          --output "$out"
      '';
in
{
  home.file."Pictures/GeneratedWallpapers".source = pkgs.linkFarm "nix-wallpapers" (
    map (profile: {
      inherit (profile) name;
      path = "${generated}/wallpaper_${profile.resolution}";
    }) profiles
  );

  home.activation.wallpaperSymlink = lib.hm.dag.entryAfter [ "linkGeneration" ] /* sh */ ''
    if [ ! -e ${lib.escapeShellArg activeWallpaper} ] && [ ! -L ${lib.escapeShellArg activeWallpaper} ]; then
      run ${pkgs.coreutils}/bin/ln -s -- \
        ${lib.escapeShellArg "GeneratedWallpapers/${(builtins.head profiles).name}"} \
        ${lib.escapeShellArg activeWallpaper}
    fi
  '';
}
