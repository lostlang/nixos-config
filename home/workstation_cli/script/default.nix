{ pkgs, ... }:
{

  home.packages = [
    (import ./clean_script.nix { inherit pkgs; })
    (import ./steam_clip_builder.nix { inherit pkgs; })
  ];
}
