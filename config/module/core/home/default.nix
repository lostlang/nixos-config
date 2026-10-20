{
  extraLocalModules,
  stateVersion,
  user,
  ...
}:
{
  imports = [
    ./bitwarden-cli-config.nix
    ./btop
    ./make-sandbox
    ./nvim
    ./tmux
    ./zellij
    ./zsh

    ./env.nix
    ./git.nix
    ./ssh.nix
    ./system-clean.nix
  ]
  ++ map (name: ../../${name}/home) extraLocalModules;

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    inherit stateVersion;
  };
}
