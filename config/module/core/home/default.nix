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

    ./bash.nix
    ./env.nix
    ./git.nix
    ./ssh.nix
    ./starship.nix
    ./system-clean.nix
  ]
  ++ map (name: ../../${name}/home) extraLocalModules;

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    inherit stateVersion;
  };
}
