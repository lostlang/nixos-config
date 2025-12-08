{
  imports = [
    ./plugins

    ./commands.nix
    ./core.nix
    ./diagnostic.nix
    ./keymap.nix
  ];

  programs.nixvim = {
    enable = true;

    nixpkgs.config.allowUnfree = true;
  };
}
