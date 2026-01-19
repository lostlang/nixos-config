{
  imports = [
    ./plugins

    ./commands.nix
    ./core.nix
    ./diagnostic.nix
    ./keymap.nix
  ];

  stylix.targets.nixvim.enable = false;

  programs.nixvim = {
    enable = true;

    nixpkgs.config.allowUnfree = true;
  };
}
