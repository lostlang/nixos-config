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

    cmd = [
      "${pkgs.writeShellScript "rust-analyzer-sandbox" ''
        set -euo pipefail

        host_cargo_home="''${CARGO_HOME:-$HOME/.cargo}"
        mkdir -p "$host_cargo_home"

        isoHome="$HOME/.local/share/nvim/bwrap/home-rust"
        mkdir -p "$isoHome" "$isoHome/.config/rust-analyzer" "$isoHome/target"


        exec ${lib.getExe pkgs.bubblewrap} \
          --unshare-all \
          --die-with-parent \
          --proc /proc \
          --dev /dev \
          --tmpfs /tmp \
          --ro-bind /nix/store /nix/store \
          --ro-bind /etc/resolv.conf /etc/resolv.conf \
          --bind "$isoHome" /home/user \
          --bind "$host_cargo_home" /cargo \
          --bind "$PWD" "$PWD" \
          --chdir "$PWD" \
          --setenv HOME /home/user \
          --setenv CARGO_HOME /cargo \
          --setenv CARGO_TARGET_DIR /home/user/target \
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
