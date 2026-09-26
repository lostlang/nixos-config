{
  extraLocalModules,
  stateVersion,
  user,
  ...
}:
{
  imports = [
    ./btop
    ./nvim
    ./zellij
    ./zsh

    ./env.nix
    ./git.nix
    ./ssh.nix
    ./tmux.nix
  ]
  ++ map (name: ../../${name}/home) extraLocalModules;

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    inherit stateVersion;
  };
}
