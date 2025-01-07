{ pkgs, user, ... }: {
programs.zsh.enable = true;

users = {
    defaultUserShell = pkgs.zsh;
    users.${user} = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" ];
        openssh.authorizedKeys.keyFiles = [ "$HOME/.ssh/id_ed25519" ];
    };
};

services.getty.autologinUser = user;
}
