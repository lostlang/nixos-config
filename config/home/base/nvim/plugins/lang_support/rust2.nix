{
  lib,
  pkgs,
  ...
}:
let
  rustAnalyzerSandbox = pkgs.writeShellScript "rust-analyzer-sandbox" ''
    set -euo pipefail

    cargoHome="''${CARGO_HOME:-$HOME/.cargo}"
    mkdir -p "$cargoHome"

    isoHome="$HOME/.local/share/nvim/bwrap/home-rust"
    mkdir -p "$isoHome" "$isoHome/.config/rust-analyzer" "$isoHome/target"

    exec ${lib.getExe pkgs.bubblewrap} \
      --unshare-all \
      --share-net \
      --die-with-parent \
      --proc /proc \
      --dev /dev \
      --tmpfs /tmp \
      --ro-bind /nix/store /nix/store \
      --ro-bind /etc/resolv.conf /etc/resolv.conf \
      --bind "$isoHome" /home/user \
      --bind "$cargoHome" "$cargoHome" \
      --bind "$PWD" "$PWD" \
      --chdir "$PWD" \
      --setenv HOME /home/user \
      --setenv CARGO_HOME "$cargoHome" \
      --setenv CARGO_TARGET_DIR /home/user/target \
      --setenv SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
      --setenv SSL_CERT_DIR "${pkgs.cacert}/etc/ssl/certs" \
      --setenv PATH "${
        pkgs.lib.makeBinPath (
          with pkgs;
          [
            cargo
            gcc

            # project deps
            protobuf
          ]
        )
      }" \
      ${lib.getExe pkgs.rust-analyzer-unwrapped} "$@"
  '';

  # rustAnalyzerProcMacroSrvSandbox = pkgs.writeShellScript "rust-analyzer-proc-macro-srv-sandbox" ''
  #   set -euo pipefail
  #
  #   cargoHome="''${CARGO_HOME:-$HOME/.cargo}"
  #   mkdir -p "$cargoHome"
  #
  #   isoHome="$HOME/.local/share/nvim/bwrap/home-rust"
  #   mkdir -p "$isoHome" "$isoHome/.config/rust-analyzer" "$isoHome/target"
  #
  #   exec ${lib.getExe pkgs.bubblewrap} \
  #     --unshare-all \
  #     --share-net \
  #     --die-with-parent \
  #     --proc /proc \
  #     --dev /dev \
  #     --tmpfs /tmp \
  #     --ro-bind /nix/store /nix/store \
  #     --ro-bind /etc/resolv.conf /etc/resolv.conf \
  #     --bind "$isoHome" /home/user \
  #     --bind "$cargoHome" "$cargoHome" \
  #     --bind "$PWD" "$PWD" \
  #     --chdir "$PWD" \
  #     --setenv HOME /home/user \
  #     --setenv CARGO_HOME "$cargoHome" \
  #     --setenv CARGO_TARGET_DIR /home/user/target \
  #     --setenv RUST_ANALYZER_INTERNALS_DO_NOT_USE 1 \
  #     --setenv SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
  #     --setenv SSL_CERT_DIR "${pkgs.cacert}/etc/ssl/certs" \
  #     --setenv PATH "${
  #       pkgs.lib.makeBinPath (
  #         with pkgs;
  #         [
  #           cargo
  #           gcc
  #           rust-analyzer-unwrapped
  #
  #           # project deps
  #           protobuf
  #         ]
  #       )
  #     }" \
  #     ${pkgs.rust-analyzer-unwrapped}/bin/rust-analyzer-proc-macro-srv "$@"
  # '';
in
{
  programs.nixvim.extraConfigLua = ''
    vim.lsp.config("rust_analyzer_isolated", {
      cmd = { "${rustAnalyzerSandbox}" },
      filetypes = { "rust" },
      root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        on_dir(vim.fs.root(fname, { "Cargo.toml", "rust-project.json", ".git" }))
      end,
      settings = {
        ["rust-analyzer"] = {
          procMacro = {
            enable = false,
          },
          cargo = {
            buildScripts = {
              enable = true,
            },
            sysroot = "${pkgs.rustc}",
            sysrootSrc = "${pkgs.rustPlatform.rustLibSrc}",
          },
        },
      },
    })

    vim.lsp.enable("rust_analyzer_isolated")
  '';
}
