{
  extraLocalModules,
  stateVersion,
  user,
  ...
}:
{
  imports = [
    ./btop
    ./bitwarden-cli-config.nix
    ./nvim
    ./zellij
    ./zsh

    ./env.nix
    ./git.nix
    ./ssh.nix
    ./tmux.nix

    ../../../preset/home/script.nix
  ]
  ++ map (name: ../../${name}/home) extraLocalModules;

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    inherit stateVersion;
  };
}
