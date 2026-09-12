{
  imports = [
    ./lang_support

    ./cmp.nix
    ./lsp.nix
    ./treesitter.nix
    ./trouble.nix
  ];

  programs.nixvim.plugins = {
    windsurf-nvim.enable = true;
  };
}
