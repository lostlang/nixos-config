{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        serverAliveInterval = 120;
        hashKnownHosts = true;
        addKeysToAgent = "yes";
        identityFile = "~/.ssh/default_ed25519";
      };
      "github.com".identityFile = "~/.ssh/github_ed25519";
    };
  };
}
