{
  lib,
  pkgs,
  ...
}:
{
  programs.nixvim.plugins.lsp.servers.gopls = {
    enable = true;

    cmd = [
      "${pkgs.writeShellScript "gopls-sandbox" ''
        set -euo pipefail

        host_gopath="''${GOPATH:-$HOME/go}"
        host_gocache="''${GOCACHE:-$HOME/.cache/go-build}"
        mkdir -p "$host_gopath" "$host_gocache"

        isoHome="$HOME/.local/share/nvim/bwrap/home-go"
        mkdir -p "$isoHome"

        exec ${lib.getExe pkgs.bubblewrap} \
          --unshare-all \
          --die-with-parent \
          --proc /proc \
          --dev /dev \
          --tmpfs /tmp \
          --ro-bind /nix/store /nix/store \
          --ro-bind /etc/resolv.conf /etc/resolv.conf \
          --bind "$isoHome" /home/user \
          --bind "$host_gopath" /go \
          --bind "$host_gocache" /gocache \
          --bind "$PWD" "$PWD" \
          --chdir "$PWD" \
          --setenv HOME /home/user \
          --setenv GOPATH /go \
          --setenv GOMODCACHE /go/pkg/mod \
          --setenv GOCACHE /gocache \
          --setenv PATH "${
            pkgs.lib.makeBinPath (
              with pkgs;
              [
                go
              ]
            )
          }" \
          ${lib.getExe pkgs.gopls}
      ''}"
    ];
  };
}
