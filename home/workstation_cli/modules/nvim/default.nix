{
  imports = [
    ./plugins

    ./core.nix
    ./key.nix
    ./diagnostics.nix
  ];

  programs.nixvim = {
    enable = true;
  };
}
