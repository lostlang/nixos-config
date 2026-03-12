{
  description = "Nodejs dev shell (flake)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://www.nixhub.io/packages/nodejs
    nixpkgs-nodejs.url = "";
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      nixpkgs-nodejs,
      treefmt-nix,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);

      treefmt = {
        projectRootFile = ".git/config";

        programs.nixfmt.enable = true;
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
          npmModuleRoots = [ ];

          pkgs = import nixpkgs { inherit system; };
          pkgsNodejs = import nixpkgs-nodejs { inherit system; };

          baseInputs = with pkgs; [
            bash
            bubblewrap
            cacert
            coreutils
            direnv
            ncurses
            procps
          ];

          extraInputs = (with pkgsNodejs; [ nodejs_24 ]) ++ (with pkgs; [ ]);

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
          npmDirs = pkgs.lib.concatStringsSep " " (
            map (path: "$HOST_PROJECT_ROOT/${path}/node_modules $HOST_PROJECT_ROOT/${path}/dist") npmModuleRoots
          );
          bwrapNpmArgs = pkgs.lib.concatStringsSep " " (
            map (path: ''
              --bind "$HOST_PROJECT_ROOT/${path}/node_modules" "/home/user/project/${path}/node_modules"
              --bind "$HOST_PROJECT_ROOT/${path}/dist" "/home/user/project/${path}/dist"
            '') npmModuleRoots
          );
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
                local host_env_allowlist
                local bwrap_chdir
                local -a bwrap_host_env_args
                local -a bwrap_args
                export HOST_PROJECT_ROOT="$(project_root)"
                bwrap_chdir="$(bwrap_chdir_for_cwd)"
                host_env_allowlist=(${hostEnvPassthroughArgs})
                bwrap_host_env_args=()
                for name in "''${host_env_allowlist[@]}"; do
                  if [ -n "''${!name+x}" ]; then
                    bwrap_host_env_args+=(--setenv "$name" "''${!name}")
                  fi
                done
                mkdir -p ${npmDirs}

                bwrap_args=(
                  --clearenv
                  --unshare-all
                  --share-net
                  --die-with-parent
                  --proc /proc
                  --dev /dev
                  --tmpfs /tmp
                  --tmpfs /home
                  --dir /usr
                  --dir /usr/bin
                  --ro-bind /nix/store /nix/store
                  --ro-bind /etc/resolv.conf /etc/resolv.conf
                  --ro-bind ${pkgs.coreutils}/bin/env /usr/bin/env
                  --ro-bind "$HOST_PROJECT_ROOT" /home/user/project
                  ${bwrapNpmArgs}
                  --chdir "$bwrap_chdir"
                  --setenv PATH "${pkgs.lib.makeBinPath buildInputs}"
                  --setenv LD_LIBRARY_PATH "${libPath}"
                  --setenv LIBRARY_PATH "${libPath}"
                  --setenv PKG_CONFIG_PATH "${pkgConfigPath}"
                  --setenv TERM "xterm-256color"
                  --setenv TERMINFO "${pkgs.ncurses}/share/terminfo"
                  --setenv HOME /home/user
                  --setenv HOST_PROJECT_ROOT /home/user/project
                  --setenv SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                  --setenv SSL_CERT_DIR "${pkgs.cacert}/etc/ssl/certs"
                  --setenv BWRAP_ACTIVE 1
                  ${bwrapEnvArgs}
                )
                bwrap_args+=("''${bwrap_host_env_args[@]}")

                exec bwrap "''${bwrap_args[@]}" \
                  bash -lc 'if [ -f "$HOST_PROJECT_ROOT/.envrc" ]; then eval "$(direnv allow $HOST_PROJECT_ROOT)"; eval "$(direnv export bash $HOST_PROJECT_ROOT)"; fi; echo "🔒 Run bwrap for an isolated shell"; echo -e "\e[32m⬢\e[0m Nodejs version: $(node -v)"; exec bash -i'
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
