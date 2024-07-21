{ ... }: {
	imports = [
		./modules/bundle.nix
	];

	home = {
		username = "nixos";
		homeDirectory = /home/nixos;
		stateVersion = "24.05";
	};
}
