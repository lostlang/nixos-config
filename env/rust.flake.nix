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
          ];

          extraInputs = (with pkgsCargo; [ cargo ]) ++ (with pkgs; [ gcc ]);

          libInputs = with pkgs; [ ];

          buildInputs = baseInputs ++ extraInputs;
          libPath = pkgs.lib.makeLibraryPath libInputs;
          pkgConfigPath = pkgs.lib.makeSearchPath "lib/pkgconfig" libInputs;

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
              project_root() {
                git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || pwd -P
              }

              bwrap_chdir_for_cwd() {
                local host_rel_path
                host_rel_path="$(git -C "$PWD" rev-parse --show-prefix 2>/dev/null || true)"
                if [ -n "$host_rel_path" ]; then
                  echo "/home/user/project/''${host_rel_path%/}"
                else
                  echo "/home/user/project"
                fi
              }

              bwrap-env() {
                local host_cargo_home
                local host_cargo_target
                local host_env_allowlist
                local bwrap_chdir
                local -a bwrap_host_env_args
                local -a bwrap_args
                host_cargo_home="''${CARGO_HOME:-$HOME/.cargo}"
                export HOST_PROJECT_ROOT="$(project_root)"
                bwrap_chdir="$(bwrap_chdir_for_cwd)"
                host_cargo_target="''${CARGO_TARGET_DIR:-$HOST_PROJECT_ROOT/target}"
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
                  --ro-bind /nix/store /nix/store
                  --ro-bind /etc/resolv.conf /etc/resolv.conf
                  --ro-bind "$HOST_PROJECT_ROOT" /home/user/project
                  --bind "$host_cargo_home" /home/user/.cargo
                  --bind "$host_cargo_target" /home/user/project/target
                  --chdir "$bwrap_chdir"
                  --setenv PATH "${pkgs.lib.makeBinPath buildInputs}"
                  --setenv LD_LIBRARY_PATH "${libPath}"
                  --setenv LIBRARY_PATH "${libPath}"
                  --setenv PKG_CONFIG_PATH "${pkgConfigPath}"
                  --setenv TERM "xterm-256color"
                  --setenv TERMINFO "${pkgs.ncurses}/share/terminfo"
                  --setenv HOME /home/user
                  --setenv HOST_PROJECT_ROOT /home/user/project
                  --setenv CARGO_HOME /home/user/.cargo
                  --setenv CARGO_TARGET_DIR /home/user/project/target
                  --setenv SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                  --setenv SSL_CERT_DIR "${pkgs.cacert}/etc/ssl/certs"
                  --setenv BWRAP_ACTIVE 1
                  ${bwrapEnvArgs}
                )
                bwrap_args+=("''${bwrap_host_env_args[@]}")

                exec bwrap "''${bwrap_args[@]}" \
                  bash -lc 'if [ -f "$HOST_PROJECT_ROOT/.envrc" ]; then eval "$(direnv allow $HOST_PROJECT_ROOT)"; eval "$(direnv export bash $HOST_PROJECT_ROOT)"; fi; echo "🔒 Run bwrap for an isolated shell"; echo "🦀 Cargo version: $(cargo version)"; exec bash -i'
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
              project_root() {
                git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || pwd -P
              }

              export HOST_PROJECT_ROOT="$(project_root)"

              ${bwrapEnvExports}
              if [ -f "$HOST_PROJECT_ROOT/.envrc" ]; then
                eval "$(direnv allow $HOST_PROJECT_ROOT)"
                eval "$(direnv export bash $HOST_PROJECT_ROOT)"
              fi
              echo "Insecure dev shell"
            '';
          };
        }
      );
    };
}
