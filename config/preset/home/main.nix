{
  config,
  pkgs,
  ...
}:
let
  system-clean = pkgs.callPackage ../../script/system-clean {
    inherit (config) programs;
  };
in
{
  programs = {
    lazygit.enable = true;
  };

  home.packages = [ system-clean ];
}
