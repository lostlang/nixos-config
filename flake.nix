{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim";

    treefmt-nix.url = "github:numtide/treefmt-nix";

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
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      stateVersion = "24.11";
      user = "lostlang";
      hosts = [
        {
          hostname = "wsl";
          core = "workstation";
        }
        {
          hostname = "h56";
          core = "workstation";
        }
      ];

      makeSystem =
        {
          hostname,
          core,
          stateVersion,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              hostname
              stateVersion
              user
              ;
          };

          modules = [
            ./hosts/${hostname}
            ./core/default
            ./core/${core}
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
            inherit (host) hostname core;
            inherit stateVersion;
          };
        }
      ) { } hosts;

      homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs stateVersion user;
        };

        modules = [
          nixvim.homeManagerModules.nixvim
          ./home
        ];
      };
    };
}
