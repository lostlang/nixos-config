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
    enableDefaultConfig = false;

    includes = lib.optional (allHosts != [ ]) hostsPath;
    settings = {
      "*" = {
        ServerAliveInterval = 120;
        HashKnownHosts = true;
        AddKeysToAgent = "yes";
        IdentityFile = "~/.ssh/default_ed25519";
      };
      "github.com".IdentityFile = "~/.ssh/github_ed25519";
    };
  };
}
