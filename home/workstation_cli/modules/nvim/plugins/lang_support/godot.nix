{ pkgs, ... }:
{

  # programs.nixvim.plugins.lsp.servers = {
  #   gdscript = {
  #     enable = true;
  #     package = pkgs.gdtoolkit_4;
  #     cmd = [ "godot-wsl-lsp" ];
  #   };
  #   gdshader_lsp.enable = true;
  # };

  programs.nixvim.plugins.none-ls.sources.formatting = {
    gdformat.enable = true;
  };

  # programs.nixvim.extraConfigLua = ''
  #   require'lspconfig'.gdscript.setup{capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())}
  # '';
}
