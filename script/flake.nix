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
      scriptSource = lib.cleanSourceWith {
        src = ./.;
        filter =
          path: _:
          let
            name = baseNameOf path;
          in
          !(builtins.elem name [
            ".env"
            ".venv"
            "__pycache__"
            ".git"
          ])
          && !(lib.hasPrefix ".env." name)
          && !(lib.hasSuffix ".pyc" name)
          && !(lib.hasSuffix ".pyo" name);
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
                  printf '%s\n' '${scriptSource}' > "$out/${pkgs.python3.sitePackages}/scripts.pth"
                  ln -s ${scriptSource} "$out/scripts"
                '';
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
