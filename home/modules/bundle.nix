{ ... }: {
imports = [
	./langs/bundle.nix
	./nixvim/init.nix
	./git.nix
	./packages.nix
	./rustup.nix
	./zellij.nix
	./zsh.nix
];
}
