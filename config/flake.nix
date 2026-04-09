{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      sops-nix,
      home-manager,
      stylix,
      nix-index-database,
      nixvim,
      nixos-wsl,
      ...
    }@inputs:
    let
      stateVersion = "25.11";
      user = "lostlang";
      colorScheme = import ./colorScheme;
      secretPath = "/home/${user}/.secret/";

      hosts = [
        {
          hostname = "wsl";
          system = "x86_64-linux";
          extraExternalModules = {
            system = [
              nixos-wsl.nixosModules.default
            ];
            home = [ ];
          };
          extraLocalModules = [ ];
        }
        {
          hostname = "h56";
          system = "x86_64-linux";
          extraExternalModules = {
            system = [ ];
            home = [ ];
          };
          extraLocalModules = [ "gui" ];
        }
      ];

    in
    {
      nixosConfigurations = nixpkgs.lib.foldl' (
        configs: host:
        configs
        // {
          "${host.hostname}" = nixpkgs.lib.nixosSystem {
            inherit (host) system;
            specialArgs = {
              inherit (host)
                extraLocalModules
                hostname
                system
                ;
              inherit
                colorScheme
                inputs
                secretPath
                stateVersion
                user
                ;
              pkgsStable = import nixpkgs-stable {
                inherit (host) system;
                config.allowUnfree = true;
              };
            };
            modules = [
              ./host/${host.hostname}/system
              ./system
              sops-nix.nixosModules.sops
              stylix.nixosModules.stylix
              nix-index-database.nixosModules.default
              {
                programs.nix-index-database.comma.enable = true;
              }
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit (host)
                      extraLocalModules
                      system
                      ;
                    inherit
                      colorScheme
                      inputs
                      secretPath
                      stateVersion
                      user
                      ;
                    pkgsStable = import nixpkgs-stable {
                      inherit (host) system;
                      config.allowUnfree = true;
                    };
                  };
                  users.${user}.imports = [
                    ./host/${host.hostname}/home
                    ./home
                    nixvim.homeModules.nixvim
                  ]
                  ++ (host.extraExternalModules.home or [ ]);
                };
              }
            ]
            ++ (host.extraExternalModules.system or [ ]);
          };
        }
      ) { } hosts;
    };
}
