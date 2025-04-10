{
  imports = [
    ./plugins

    ./core.nix
    ./diagnostics.nix
    ./fold.nix
    ./keymap.nix
  ];

  programs.nixvim = {
    enable = true;

    nixpkgs.config.allowUnfree = true;
  };
}
