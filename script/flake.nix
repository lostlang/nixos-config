{
  description = "Python environment built from uv.lock";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      systems,
      nixpkgs,
      uv2nix,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs (import systems);
      workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };
      overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };
      librarySource = lib.cleanSourceWith {
        src = ./lib;
        filter =
          path: type:
          lib.cleanSourceFilter path type
          && baseNameOf path != "__pycache__"
          && !(lib.hasSuffix ".pyc" (baseNameOf path))
          && !(lib.hasSuffix ".pyo" (baseNameOf path));
      };
    in
    {
      packages = eachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          pythonSet =
            (pkgs.callPackage uv2nix.inputs.pyproject-nix.build.packages {
              python = pkgs.python3;
            }).overrideScope
              overlay;
          pythonEnvironment =
            (pythonSet.mkVirtualEnv "nixos-scripts-env" workspace.deps.default).overrideAttrs
              (old: {
                postInstall = (old.postInstall or "") + /* sh */ ''
                  ln -s ${librarySource} "$out/${pkgs.python3.sitePackages}/lib"
                '';
                passthru = (old.passthru or { }) // {
                  script =
                    name:
                    builtins.path {
                      path = ./. + "/${name}";
                      name = baseNameOf name;
                    };
                };
              });
        in
        {
          python-env = pythonEnvironment;
          default = pythonEnvironment;
        }
      );

      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              uv
              direnv
              secretspec
              python3
            ];

            SECRETSPEC_PROFILE = "vps72c411b0";
            SECRETSPEC_PROVIDER = "bao-approle";

            UV_PYTHON = "${pkgs.python3}/bin/python";
            UV_PYTHON_DOWNLOADS = "never";

            shellHook = /* sh */ ''
              eval "$(${lib.getExe pkgs.direnv} allow)"
              eval "$(${lib.getExe pkgs.direnv} hook bash)"
              alias run='secretspec run -- uv run'
            '';
          };
        }
      );
    };
}
