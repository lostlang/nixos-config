{ pkgs, ... }: {
home.packages = with pkgs; [
	neofetch
	htop
	zellij
	# degit

	go
	python313
	bun
	nodejs_22
];
}
