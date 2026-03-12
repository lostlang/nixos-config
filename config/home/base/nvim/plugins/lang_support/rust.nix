{
  lib,
  pkgs,
  ...
}:
{
  programs.nixvim.plugins.lsp.servers.rust_analyzer = {
    enable = true;
    installCargo = true;
    installRustc = false;

    settings = {
      procMacro = {
        enable = false;
        # enable = true;
        # server = "${pkgs.rust-analyzer-unwrapped}/bin/rust-analyzer-proc-macro-srv";
        # server = pkgs.writeShellScript "proc-macro-srv-sandbox" ''
        #   set -euo pipefail
        #
        #   host_cargo_home="''${CARGO_HOME:-$HOME/.cargo}"
        #   mkdir -p "$host_cargo_home"
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
        #     --bind "$host_cargo_home" "$host_cargo_home" \
        #     --bind "$PWD" "$PWD" \
        #     --chdir "$PWD" \
        #     --setenv HOME /home/user \
        #     --setenv CARGO_HOME "$host_cargo_home" \
        #     --setenv CARGO_TARGET_DIR /home/user/target \
        #     --setenv RUST_ANALYZER_INTERNALS_DO_NOT_USE 1 \
        #     --setenv SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
        #     --setenv SSL_CERT_DIR "${pkgs.cacert}/etc/ssl/certs" \
        #     --setenv PATH "${
        #       pkgs.lib.makeBinPath (with pkgs; [
        #         cargo
        #         gcc
        #         rust-analyzer-unwrapped
        #
        #         # project deps
        #         protobuf
        #       ])
        #     }" \
        #     ${pkgs.rust-analyzer-unwrapped}/bin/rust-analyzer-proc-macro-srv "$@"
        # '';
      };
      cargo = {
        buildScripts.enable = true;
      };
    };

    cmd = [
      "${pkgs.writeShellScript "rust-analyzer-sandbox" ''
        set -euo pipefail

        host_cargo_home="''${CARGO_HOME:-$HOME/.cargo}"
        mkdir -p "$host_cargo_home"

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
          --bind "$host_cargo_home" "$host_cargo_home" \
          --bind "$PWD" "$PWD" \
          --chdir "$PWD" \
          --setenv HOME /home/user \
          --setenv CARGO_HOME "$host_cargo_home" \
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
          ${lib.getExe pkgs.rust-analyzer}
      ''}"
    ];
  };
}
