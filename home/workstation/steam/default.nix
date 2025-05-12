{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      withPrimus = true;
      extraPkgs = with pkgs; [
        bumblebee
        glxinfo
      ];
    };
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  home.packages = with pkgs; [
    vulkan-tools
    mesa
    glxinfo
  ];
}
