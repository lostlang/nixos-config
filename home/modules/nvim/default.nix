{
imports = [
	./plugins
	./core.nix
	./key.nix
];

programs.nixvim = {
	enable = true;
};
}
