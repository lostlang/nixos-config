{
programs.ssh = {
	enable = true;
	addKeysToAgent = "yes";
	matchBlocks = {
		"*".identityFile = "$HOME/.ssh/default_ed25519";
		"github.com".identityFile = "$HOME/.ssh/github_ed25519";
	};
};
}
