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

    ./env.nix
    ./git.nix
    ./ssh.nix
    ./tmux.nix
    ./zsh.nix
  ]
  ++ map (name: ../../${name}/home) extraLocalModules;

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    inherit stateVersion;
  };
}
