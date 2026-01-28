# Instalation WSL

1. Install NixOS WLS (in Windows PowerShell) [(link)](https://github.com/nix-community/NixOS-WSL)
1. Pre configuation (in WSL)
    ```bash
    sudo nix-channel --update
    nix-shell -p git
    ```
1. Copy dots (in WSL)
    ```bash
    git clone https://github.com/lostlang/nixos-wsl-config $HOME/.config/nixos
    cd $HOME/.config/nixos
    ```
1. Generate secrets (in WSL)
    ```bash
    sudo mkdir $HOME/.secret
    sudo age-keygen -o $HOME/.secret/key 
    sudo cp template.secret.yaml $HOME/.secret/secret.yaml
    sudo chmod 0600 $HOME/.secret/secret.yaml
    ```
1. Encrypt file (in WSL)
    ```bash
    cd $HOME/.secret
    sudo -E SOPS_AGE_KEY_FILE=key sops -e -i -a <PUBLIC KEY> secret.yaml
    ```
1. Change secrets (in WSL)
    ```bash
    cd $HOME/.secret
    sudo -E SOPS_AGE_KEY_FILE=key sops secret.yaml
    ```
1. Install dots (in WSL)
    ```bash
    cd $HOME/.config/nixos/config
    sudo nixos-rebuild switch --flake .#wsl
    clean all
    ```
1. Reboot WLS (in Windows PowerShell)
    ```
    wsl --shutdown
    ```
1. Post configuration (in WSL)
    ```bash
    ssh-keygen -t ed25519 -a 100 -f ~/.ssh/default_ed25519
    ```

    ```bash
    ssh-keygen -t ed25519 -a 100 -f ~/.ssh/github_ed25519
    ```

# Windows addition
1. Install win32yank (use Scoop [(link)](https://scoop.sh/#/apps?q=win32yank))
