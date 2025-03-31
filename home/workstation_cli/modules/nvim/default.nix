{
  imports = [
    ./plugins

    ./core.nix
    ./keymap.nix
    ./diagnostics.nix
  ];

  programs.nixvim = {
    enable = true;
  };
}
