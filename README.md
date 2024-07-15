# Instalation

1. Install NixOS WLS (in Windows PowerShell) [(link)](https://github.com/nix-community/NixOS-WSL)
1. Pre configuation (in WSL)
    ```bash
    sudo nix-channel --update
    nix-shell -p git
    ```
1. Install dots (in WSL)
    ```bash
    git clone https://github.com/lostlang/nixos-wsl-config $HOME/.config/nixos
    cd $HOME/.config/nixos
    sudo nixos-rebuild switch --flake .#lostwsl
    home-manager switch --flake .
    sudo nix-collect-garbage -d
    nix-collect-garbage -d
    ```
1. Reboot WLS (in Windows PowerShell)
    ```
    wsl --shutdown
    ```
1. Post configuration (in WSL)
    ```bash
    ssh-keygen
    ```

# Windows addition
1. Install win32yank (use Scoop [(link)](https://scoop.sh/#/apps?q=win32yank))
