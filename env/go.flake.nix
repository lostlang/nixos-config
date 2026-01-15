{
  description = "Go dev shell (flake)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # https://www.nixhub.io/packages/go
    go-nixpkgs.url = "";
  };

  outputs =
    { nixpkgs, go-nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          bwrapEnv = {
            CGO_ENABLED = 1;
            GOPRIVATE = "";
          };

          hostEnvPassthrough = [ ];

          extraInputs = (with fixPkgs; [ gcc ]) ++ (with pkgs; [ ]);

          pkgs = import nixpkgs { inherit system; };
          fixPkgs = import go-nixpkgs { inherit system; };

          baseInputs =
            (with fixPkgs; [ go ])
            ++ (with pkgs; [
              bash
              bubblewrap
              ncurses
              cacert
              coreutils
              direnv
              procps
            ]);

          buildInputs = baseInputs ++ extraInputs;

          bwrapEnvArgs = pkgs.lib.concatStringsSep " " (
            pkgs.lib.mapAttrsToList (name: value: ''--setenv ${name} "${toString value}"'') bwrapEnv
          );
          hostEnvPassthroughArgs = pkgs.lib.concatStringsSep " " hostEnvPassthrough;
        in
        {
          default = pkgs.mkShell {
            inherit buildInputs;

            shellHook = ''
              bwrap-go() {
                local host_gopath
                local host_gocache
                local host_env_allowlist
                local -a bwrap_host_env_args
                local -a bwrap_args
                host_gopath="''${GOPATH:-$HOME/go}"
                host_gocache="''${GOCACHE:-$HOME/.cache/go-build}"
                host_env_allowlist=(${hostEnvPassthroughArgs})
                bwrap_host_env_args=()
                for name in "''${host_env_allowlist[@]}"; do
                  if [ -n "''${!name+x}" ]; then
                    bwrap_host_env_args+=(--setenv "$name" "''${!name}")
                  fi
                done
                mkdir -p "$host_gopath" "$host_gocache"
                if [ ! -f "$PWD/go.mod" ]; then
                  touch "$PWD/go.mod"
                fi
                if [ ! -f "$PWD/go.sum" ]; then
                  touch "$PWD/go.sum"
                fi

                bwrap_args=(
                  --clearenv
                  --unshare-all
                  --share-net
                  --die-with-parent
                  --proc /proc
                  --dev /dev
                  --tmpfs /tmp
                  --tmpfs /home
                  --ro-bind /nix /nix
                  --ro-bind /etc/resolv.conf /etc/resolv.conf
                  --ro-bind "$PWD" /home/user/project
                  --bind "$PWD/go.mod" /home/user/project/go.mod
                  --bind "$PWD/go.sum" /home/user/project/go.sum
                  --chdir /home/user/project
                  --bind "$host_gopath" /go
                  --bind "$host_gocache" /gocache
                  --setenv PATH "${pkgs.lib.makeBinPath buildInputs}"
                  --setenv TERM "xterm-256color"
                  --setenv TERMINFO "${pkgs.ncurses}/share/terminfo"
                  --setenv HOME /home/user
                  --setenv SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                  --setenv SSL_CERT_DIR "${pkgs.cacert}/etc/ssl/certs"
                  --setenv GOTOOLCHAIN local
                  --setenv GOPATH /go
                  --setenv GOMODCACHE /go/pkg/mod
                  --setenv GOCACHE /gocache
                  --setenv BWRAP_GO_ACTIVE 1
                  ${bwrapEnvArgs}
                )
                bwrap_args+=("''${bwrap_host_env_args[@]}")

                exec bwrap "''${bwrap_args[@]}" \
                  bash -lc 'eval "$(direnv allow)"; eval "$(direnv export bash)"; echo "🔒 Run bwrap for an isolated shell"; echo "🐹 Go env: $(go version)"; exec bash -i'
              }

              export -f bwrap-go
              if [ -z "$BWRAP_GO_ACTIVE" ]; then
                bwrap-go
              fi
            '';
          };
        }
      );
    };
}
