{
  programs.nixvim.plugins.lsp.servers.rust_analyzer = {
    enable = true;
    package = null;
    installCargo = false;
    installRustc = false;

    cmd = [ "rust-analyzer-sandbox" ];

    extraOptions.root_dir.__raw = /* lua */ ''
      function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, { "Cargo.lock" })
          or vim.fs.root(bufnr, { "Cargo.toml" })
          or vim.fs.root(bufnr, { ".git" })
        if root then
          on_dir(root)
        end
      end
    '';
  };
}
