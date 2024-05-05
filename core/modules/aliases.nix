{ config, ... }: {
  programs.bash = {
	shellAliases =
	let
	  flakeDir = "$HOME/.config/nixos/";
	in {
	  sudo = "sudo ";
	  rebuild-home = "home-manager switch --flake ${flakeDir}";
	  rebuild-os = "nixos-rebuild switch --flake ${flakeDir}";
	};
  };
}
