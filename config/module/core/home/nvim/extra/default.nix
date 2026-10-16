{
  imports = [
    ./lang_support
    ./treesitter

    ./blink-cmp.nix
    ./lsp.nix
    ./nerdy.nix
  ];

  programs.nixvim.plugins = {
    luasnip.enable = true;
    friendly-snippets.enable = true;

    trouble.enable = true;
  };
}
