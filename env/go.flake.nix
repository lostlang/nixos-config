{
  description = "Go dev shell (flake)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # https://www.nixhub.io/packages/go
    nixpkgs-go.url = "";
  };

  outputs =
    {
      systems,
      nixpkgs,
      nixpkgs-go,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = eachSystem (
        system:
        let
          bwrapEnv = {
            CGO_ENABLED = 1;
            GOPRIVATE = "";
          };
          hostEnvPassthrough = [ ];

          pkgs = import nixpkgs { inherit system; };
          pkgsGo = import nixpkgs-go { inherit system; };

          extraInputs = (with pkgsGo; [ go ]) ++ (with pkgs; [ gcc ]);

          baseInputs = with pkgs; [
            bash
            bubblewrap
            ncurses
            cacert
            coreutils
            direnv
            procps
            tmux
          ];

          buildInputs = baseInputs ++ extraInputs;

          bwrapEnvArgs = pkgs.lib.concatStringsSep " " (
            pkgs.lib.mapAttrsToList (
              name: value: "--setenv ${name} ${pkgs.lib.escapeShellArg (toString value)}"
            ) bwrapEnv
          );
          bwrapEnvExports = pkgs.lib.concatStringsSep "\n" (
            pkgs.lib.mapAttrsToList (
              name: value: "export ${name}=${pkgs.lib.escapeShellArg (toString value)}"
            ) bwrapEnv
          );
          hostEnvPassthroughArgs = pkgs.lib.concatStringsSep " " hostEnvPassthrough;
        in
        {
          default = pkgs.mkShell {
            inherit buildInputs;

            shellHook = ''
              bwrap-env() {
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
                  --setenv BWRAP_ACTIVE 1
                  ${bwrapEnvArgs}
                )
                bwrap_args+=("''${bwrap_host_env_args[@]}")

                exec bwrap "''${bwrap_args[@]}" \
                  bash -lc 'if [ -f "$PWD/.envrc" ]; then eval "$(direnv allow)"; eval "$(direnv export bash)"; fi; echo "🔒 Run bwrap for an isolated shell"; echo "🐹 Go env: $(go version)"; exec bash -i'
              }

              export -f bwrap-env
              if [ -z "$BWRAP_ACTIVE" ]; then
                bwrap-env
              fi
            '';
          };

          insecure = pkgs.mkShell {
            inherit buildInputs;

            shellHook = ''
              ${bwrapEnvExports}
              if [ -f "$PWD/.envrc" ]; then
                eval "$(direnv allow)"
                eval "$(direnv export bash)"
              fi
              echo "Insecure dev shell"
            '';
          };
        }
      );
    };
}
