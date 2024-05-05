{ pkgs, ... }: {
  home.packages = with pkgs; [
    openssh
    
    # neovim
    neofetch
    degit

    go
    rustup
  ];
}