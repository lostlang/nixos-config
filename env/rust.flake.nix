{
  description = "Rust dev shell (flake)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://www.nixhub.io/packages/cargo
    nixpkgs-cargo.url = "";
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      nixpkgs-cargo,
      treefmt-nix,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);

      treefmt = {
        projectRootFile = ".git/config";

        programs.nixfmt.enable = true;
        programs.rustfmt.enable = true;
      };
      treefmtEval = eachSystem (
        system: treefmt-nix.lib.evalModule (import nixpkgs { inherit system; }) treefmt
      );
    in
    {
      formatter = eachSystem (system: treefmtEval.${system}.config.build.wrapper);

      checks = eachSystem (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });

      devShells = eachSystem (
        system:
        let
          bwrapEnv = { };
          hostEnvPassthrough = [ ];

          pkgs = import nixpkgs { inherit system; };
          pkgsCargo = import nixpkgs-cargo { inherit system; };

          baseInputs = with pkgs; [
            bash
            bubblewrap
            cacert
            coreutils
            direnv
            ncurses
            procps
            tmux
          ];

          extraInputs = (with pkgsCargo; [ cargo ]) ++ (with pkgs; [ gcc ]);

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
                local host_cargo_home
                local host_cargo_target
                local host_env_allowlist
                local -a bwrap_host_env_args
                local -a bwrap_args
                host_cargo_home="''${CARGO_HOME:-$HOME/.cargo}"
                host_cargo_target="''${CARGO_TARGET_DIR:-$PWD/target}"
                host_env_allowlist=(${hostEnvPassthroughArgs})
                bwrap_host_env_args=()
                for name in "''${host_env_allowlist[@]}"; do
                  if [ -n "''${!name+x}" ]; then
                    bwrap_host_env_args+=(--setenv "$name" "''${!name}")
                  fi
                done
                mkdir -p "$host_cargo_home" "$host_cargo_target"

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
                  --bind "$host_cargo_home" /home/user/.cargo
                  --bind "$host_cargo_target" /home/user/project/target
                  --chdir /home/user/project
                  --setenv PATH "${pkgs.lib.makeBinPath buildInputs}"
                  --setenv TERM "xterm-256color"
                  --setenv TERMINFO "${pkgs.ncurses}/share/terminfo"
                  --setenv HOME /home/user
                  --setenv CARGO_HOME /home/user/.cargo
                  --setenv CARGO_TARGET_DIR /home/user/project/target
                  --setenv SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                  --setenv SSL_CERT_DIR "${pkgs.cacert}/etc/ssl/certs"
                  --setenv BWRAP_ACTIVE 1
                  ${bwrapEnvArgs}
                )
                bwrap_args+=("''${bwrap_host_env_args[@]}")

                exec bwrap "''${bwrap_args[@]}" \
                  bash -lc 'if [ -f "$PWD/.envrc" ]; then eval "$(direnv allow)"; eval "$(direnv export bash)"; fi; echo "🔒 Run bwrap for an isolated shell"; echo "🦀 Cargo version: $(cargo version)"; exec bash -i'
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
