{ pkgs, ... }: {
  home.packages = with pkgs; [
    # neovim
    neofetch
    degit

    go
    rustup
  ];
}