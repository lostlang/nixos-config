{
inputs = {
	nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
	nixos-wsl = {
		url = github:nix-community/NixOS-WSL/main;
		inputs.nixpkgs.follows = "nixpkgs";
	};
	home-manager = {
		url = github:nix-community/home-manager;
		inputs.nixpkgs.follows = "nixpkgs";
	};
	nixvim = {
		url = github:nix-community/nixvim;
		inputs.nixpkgs.follows = "nixpkgs";
	};
};

outputs = 
args@{ self, nixpkgs, nixos-wsl, home-manager, nixvim, ... }:
let
	system = "x86_64-linux";
in {
	nixosConfigurations.lostwsl = nixpkgs.lib.nixosSystem {
		inherit system;
		specialArgs = args;
		modules = [
			nixvim.nixosModules.nixvim
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
