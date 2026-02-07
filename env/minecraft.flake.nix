{
  description = "Minecraft server shell (flake)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    {
      systems,
      nixpkgs,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          buildInputs = with pkgs; [ temurin-bin-21 ];
        in
        {
          default = pkgs.mkShell {
            inherit buildInputs;
          };
        }
      );
    };
}
