{
  lib,
  osConfig,
  ...
}:
let
  keys = osConfig.myConfig.ssh.keys;
  includePath = osConfig.sops.templates."ssh/hosts.conf".path;
in
{
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    includes = lib.optional (keys != [ ]) includePath;
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
