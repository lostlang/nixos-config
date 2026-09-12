{
  lib,
  osConfig,
  ...
}:
let
  inherit (osConfig.myConfig.ssh) hosts identities vpsHosts;
  allHosts = lib.unique (identities ++ hosts ++ vpsHosts);
  hostsPath = osConfig.sops.templates."ssh/hosts.conf".path;
in
{
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;

    includes = lib.optional (allHosts != [ ]) hostsPath;
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
