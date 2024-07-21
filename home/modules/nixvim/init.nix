{ ... }: {
imports = [
	./plugins/bundle.nix
	./base.nix
];
programs.nixvim = {
	enable = true;
};
}
