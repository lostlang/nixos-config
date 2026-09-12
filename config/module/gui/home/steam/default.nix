{
  pkgs,
  ...
}:
{
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      withPrimus = true;
      extraPkgs = with pkgs; [
        bumblebee
        glxinfo
      ];
    };
  };

  home.packages = with pkgs; [
    vulkan-tools
    mesa
    glxinfo
  ];
}
