{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager.url = "github:nix-community/home-manager/release-24.11";

    nixvim.url = "github:nix-community/nixvim";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    stylix.url = "github:danth/stylix/release-24.11";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    potatofox = {
      url = "git+https://codeberg.org/awwpotato/PotatoFox";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixvim,
      systems,
      treefmt-nix,
      stylix,
      nixos-wsl,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      stateVersion = "24.11";
      user = "lostlang";
      hosts = [
        {
          hostname = "wsl";
          system_type = "server";
          window_manager = "none";
        }
        {
          hostname = "h56";
          system_type = "workstation";
          window_manager = "gnome";
        }
      ];

      makeSystem =
        {
          hostname,
          system_type,
          window_manager,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              system
              stateVersion
              hostname
              user
              system_type
              window_manager
              ;
          };

          modules = [
            stylix.nixosModules.stylix
            nixos-wsl.nixosModules.default
            ./hosts/${hostname}
            ./core
          ];
        };

      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./pre_config/treefmt.nix);
    in
    {
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      nixosConfigurations = nixpkgs.lib.foldl' (
        configs: host:
        configs
        // {
          "${host.hostname}" = makeSystem {
            inherit (host) hostname system_type window_manager;
          };
        }
      ) { } hosts;

      homeConfigurations =
	nixpkgs.lib.foldl' (
          configs: host:
          configs
          // {
		  "${user}@${host.hostname}" =  home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = 

 		{
            inherit (host) system_type;
            inherit inputs stateVersion user;
          }
        ;

        modules = [
          nixvim.homeManagerModules.nixvim
          ./home
        ];
      };}
	  ) { } hosts;
    };
}
