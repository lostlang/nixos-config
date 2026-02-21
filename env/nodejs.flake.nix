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

          extraInputs =
            (with pkgsNodejs; [ nodejs_24 ])
            ++ (with pkgs; [
              gcc
              protobuf
            ]);

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
          npmDirs = pkgs.lib.concatStringsSep " " (
            map (path: "$PWD/${path}/node_modules $PWD/${path}/dist") npmModuleRoots
          );
          bwrapNpmArgs = pkgs.lib.concatStringsSep " " (
            map (path: ''
              --bind "$PWD/${path}/node_modules" "/home/user/project/${path}/node_modules"
              --bind "$PWD/${path}/dist" "/home/user/project/${path}/dist"
            '') npmModuleRoots
          );
        in
        {
          default = pkgs.mkShell {
            inherit buildInputs;

            shellHook = ''
              bwrap-env() {
                local host_env_allowlist
                local -a bwrap_host_env_args
                local -a bwrap_args
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
                  --ro-bind "$PWD" /home/user/project
                  ${bwrapNpmArgs}
                  --chdir /home/user/project
                  --setenv PATH "${pkgs.lib.makeBinPath buildInputs}"
                  --setenv TERM "xterm-256color"
                  --setenv TERMINFO "${pkgs.ncurses}/share/terminfo"
                  --setenv HOME /home/user
                  --setenv SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                  --setenv SSL_CERT_DIR "${pkgs.cacert}/etc/ssl/certs"
                  --setenv BWRAP_ACTIVE 1
                  ${bwrapEnvArgs}
                )
                bwrap_args+=("''${bwrap_host_env_args[@]}")

                exec bwrap "''${bwrap_args[@]}" \
                  bash -lc 'if [ -f "$PWD/.envrc" ]; then eval "$(direnv allow)"; eval "$(direnv export bash)"; fi; echo "🔒 Run bwrap for an isolated shell"; echo -e "\e[32m⬢\e[0m Nodejs version: $(node -v)"; exec bash -i'
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
