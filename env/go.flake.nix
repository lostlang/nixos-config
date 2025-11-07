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
      system = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; };
      goPkgs = import go-nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "go-dev";
        buildInputs = with goPkgs; [ go ];

        shellHook = ''
          export GOTOOLCHAIN=local
          echo "🐹 Go env: $(go version)"
        '';
      };
    };
}
