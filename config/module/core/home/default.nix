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
    ./nvim
    ./tmux
    ./zellij
    ./zsh

    ./env.nix
    ./git.nix
    ./ssh.nix

    ../../../preset/home/script.nix
  ]
  ++ map (name: ../../${name}/home) extraLocalModules;

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    inherit stateVersion;
  };
}
