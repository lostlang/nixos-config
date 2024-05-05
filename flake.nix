{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    nixpkgs-stable.url = github:nixos/nixpkgs/nixos-23.11;
    nixos-wsl = {
      url = github:nix-community/NixOS-WSL/main;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = 
    args@{ self, nixpkgs, nixpkgs-stable, nixos-wsl, home-manager, nixvim, ... }:
    let
      system = "x86_64-linux";
    in {
    nixosConfigurations.lostpc = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = args;
      modules = [
        # nixvim.nixosModules.nixvim
        nixos-wsl.nixosModules.default
	      ./core/configuration.nix
      ];
    };

    homeConfigurations.nixos = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [ ./home/configuration.nix ];
    };
  };
}
