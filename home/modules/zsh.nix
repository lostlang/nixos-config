{ pkgs, ... }: {
programs.zsh = {
	enable = true;
	enableCompletion = true;
	autosuggestion.enable = true;
	syntaxHighlighting.enable = true;

	shellAliases =
	let
		flakeDir = "$HOME/.config/nixos/";
	in {
		rebuild-home = "home-manager switch --flake ${flakeDir}";
		rebuild-os = "sudo nixos-rebuild switch --flake ${flakeDir}";
	};

	oh-my-zsh = {
		enable = true;
		plugins = [
			"git"
			"sudo"
		];
		theme = "jonathan";
	};
};
}
