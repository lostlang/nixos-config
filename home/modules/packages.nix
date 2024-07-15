{ pkgs, ... }: {
home.packages = with pkgs; [
	neovim
	neofetch
	htop
	zellij
	# degit

	wget
	zip
	unzip

	go
	rustup
	python313
	zig
	# gcc
	gnumake
	bun
	nodejs_22
];
}
