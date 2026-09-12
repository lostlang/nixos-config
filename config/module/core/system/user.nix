{
  pkgs,
  user,
  ...
}:
{
  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    users.${user} = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSmLkFq9HTiQR0O2kIQ+qZugIGhdMzwDQtJ3cE4OkC0 lostlang@wsl"
      ];
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };
}
