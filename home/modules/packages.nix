{ pkgs, ... }: {
home.packages = with pkgs; [
	neovim
	neofetch
	htop
	zellij
	# degit

	go

	python313
	# zig
	bun
	nodejs_22
];
}
