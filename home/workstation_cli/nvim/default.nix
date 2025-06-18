{
  imports = [
    ./plugins

    ./core.nix
    ./diagnostic.nix
    ./fold.nix
    ./keymap.nix
  ];

  programs.nixvim = {
    enable = true;

    nixpkgs.config.allowUnfree = true;
  };
}
