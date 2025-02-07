{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "*".identityFile = "~/.ssh/default_ed25519";
      "github.com".identityFile = "~/.ssh/github_ed25519";
    };
  };
}
