{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  name = "minecraft-server";

  buildInputs = with pkgs; [ temurin-bin-21 ];

  shellHook = "";
}
