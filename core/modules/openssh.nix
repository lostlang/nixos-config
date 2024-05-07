{ pkgs, ... }: {
users.users.nixos.openssh.authorizedKeys.keyFiles = [
	"$HOME/.ssh/id_ed25519"
];
}
