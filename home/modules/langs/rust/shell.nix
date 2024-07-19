{ pkgs ? import <nixpkgs> {} }: pkgs.mkShell {
name = "rust";
nativeBuildInputs = with pkgs; [
	cargo
	rustc
	clang

	pkg-config
	proj
];
bulidInputs = with pkgs; [
	libclang
];

LIBCLANG_PATH="${pkgs.libclang.lib}/lib";
}
