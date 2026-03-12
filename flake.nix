{
  description = "Formatter tools for this repo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt-nix,
      pre-commit-hooks,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);

      treefmt_config = {
        projectRootFile = ".git/config";
        programs.nixfmt.enable = true;
        programs.yamlfmt.enable = true;
      };
      treefmtEval = eachSystem (
        system: treefmt-nix.lib.evalModule (import nixpkgs { inherit system; }) treefmt_config
      );

      preCommit = eachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          inherit (nixpkgs) lib;
        in
        pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            treefmt = {
              enable = true;
              name = "treefmt";
              description = "One CLI to format the code tree.";
              entry = "${lib.getExe treefmtEval.${system}.config.build.wrapper} --fail-on-change --no-cache";
              pass_filenames = false;
            };
            statix = {
              enable = true;
              after = [ "statix-fix" ];
            };
            statix-fix = {
              enable = true;
              name = "statix-fix";
              description = "Auto-fix Statix findings where possible";
              entry = "${lib.getExe pkgs.statix} fix .";
              pass_filenames = false;
            };
            deadnix.enable = true;
            gitleaks = {
              enable = true;
              name = "gitleaks";
              description = "Detect secrets with gitleaks";
              entry = "${lib.getExe pkgs.gitleaks} detect --source . --no-git --redact";
              pass_filenames = false;
            };
            check-added-large-files.enable = true;
          };
        }
      );
    in
    {
      formatter = eachSystem (system: treefmtEval.${system}.config.build.wrapper);

      checks = eachSystem (system: {
        formatting = treefmtEval.${system}.config.build.check self;
        pre-commit = preCommit.${system}.check;
      });

      devShells = eachSystem (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inputsFrom = [ preCommit.${system} ];
        };
      });
    };
}
