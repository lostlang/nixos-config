{
  imports = [
    ./plugins

    ./core.nix
    ./fold.nix
    ./keymap.nix
    ./diagnostics.nix
  ];

  programs.nixvim = {
    enable = true;

    nixpkgs.config.allowUnfree = true;
  };
}
