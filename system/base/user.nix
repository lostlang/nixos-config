{ pkgs, user, ... }:
{
  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    users.${user} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
    extraRules = [
      {
        users = [ user ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  services.getty.autologinUser = user;
}
