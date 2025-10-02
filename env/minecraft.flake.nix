{
  description = "Minecraft server shell (flake)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "minecraft-server";
        buildInputs = with pkgs; [ temurin-bin-21 ];

        shellHook = "";
      };
    };
}
