{ pkgs, ... }: {
environment.systemPackages = with pkgs; [
    openssh
	git
	home-manager
	zsh
	wget
	zip
	unzip
];
}
