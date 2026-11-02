{
  description = "Go dev shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # https://www.nixhub.io/packages/go
    nixpkgs-go.url = "";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      nixpkgs-go,
      treefmt-nix,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs (import systems);
      treefmtEval = eachSystem (
        system:
        treefmt-nix.lib.evalModule (import nixpkgs { inherit system; }) {
          programs = {
            nixfmt.enable = true;
            gofumpt.enable = true;
            goimports.enable = true;
          };
        }
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
          pkgs = import nixpkgs { inherit system; };
          pkgsGo = import nixpkgs-go { inherit system; };

          exportEnvironmentDefaults =
            defaults:
            lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: value: /* sh */ ''
                export ${name}=''${${name}:-${lib.escapeShellArg value}}
              '') defaults
            );

          hostEnvPassthrough = [ ];
          libInputs = [ ];
          runtimeInputs = with pkgs; [
            bash
            cacert
            coreutils
            direnv
            gcc
            git
            ncurses
            procps
            pkgsGo.go
          ];
          environment = {
            CGO_ENABLED = "1";
            GOPRIVATE = "";
            GOTOOLCHAIN = "local";
            GOPATH = "/go";
            GOMODCACHE = "/go/pkg/mod";
            GOCACHE = "/gocache";
          };

          sandboxArguments = [
            "--runtime-path"
            (lib.makeBinPath runtimeInputs)
            "--library-path"
            (lib.makeLibraryPath libInputs)
            "--pkg-config-path"
            (lib.makeSearchPath "lib/pkgconfig" libInputs)
          ]
          ++ lib.concatMap (name: [
            "--host-env-passthrough"
            name
          ]) hostEnvPassthrough
          ++ lib.concatLists (
            lib.mapAttrsToList (name: value: [
              "--setenv"
              name
              value
            ]) environment
          );
          sandboxStartup = /* sh */ ''
            echo "Version Go in sandbox: $(go version)"
          '';

          sandboxShell = pkgs.writeShellScript "go-sandbox-shell" /* sh */ ''
            ${sandboxStartup}
            exec ${lib.getExe pkgs.bash} --noprofile --norc -i
          '';

          makeSandboxShell =
            { readOnlyProject }:
            pkgs.mkShell {
              packages = runtimeInputs;
              shellHook =
                lib.optionalString (!readOnlyProject) /* sh */ ''
                  printf "\033[31mWarning: semi-secure shell (project is writable).\033[0m\n"
                ''
                + /* sh */ ''
                  if ! command -v make-sandbox >/dev/null 2>&1; then
                    printf '%s\n' 'Error: make-sandbox is required. Install it on your host and add it to PATH.' >&2
                    exit 1
                  fi

                  go_path="''${GOPATH:-$HOME/go}"
                  go_cache="''${GOCACHE:-$HOME/.cache/go-build}"

                  exec make-sandbox \
                    ${lib.escapeShellArgs (sandboxArguments ++ lib.optional readOnlyProject "--read-only-project")} \
                    --user "$(id -un)" \
                    --directory "$go_path" \
                    --directory "$go_cache" \
                    --bind "$go_path" /go \
                    --bind "$go_cache" /gocache \
                    -- ${sandboxShell}
                '';
            };
        in
        {
          default = makeSandboxShell { readOnlyProject = true; };
          semi-secure = makeSandboxShell { readOnlyProject = false; };

          insecure = pkgs.mkShell {
            packages = runtimeInputs;
            shellHook = (exportEnvironmentDefaults environment) + /* sh */ ''
              printf "\033[31mWarning: insecure shell (sandbox disabled).\033[0m\n"
              ${sandboxStartup}
            '';
          };
        }
      );
    };
}
