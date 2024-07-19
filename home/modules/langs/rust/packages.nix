{ pkgs, ... }: {
home.packages = with pkgs; [
	cargo
	rustc
	rustfmt

	clang
	libclang
	pkg-config
	proj
];
}
