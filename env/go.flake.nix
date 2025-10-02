{
  description = "Go dev shell (flake)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "go-dev";
        buildInputs = with pkgs; [ go ];

        shellHook = ''
          echo "🐹 Go env: $(go version)"
        '';
      };
    };
}
