{ pkgs, ... }:
{

  home.packages = [ (import ./clean_script.nix { inherit pkgs; }) ];
}
