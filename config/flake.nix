{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      disko,
      home-manager,
      nixos-wsl,
      nixvim,
      sops-nix,
      stylix,
      ...
    }@inputs:
    let
      stateVersion = "26.11";
      user = "lostlang";
      colorScheme = import ./colorScheme;
      secretPath = "/home/${user}/.secret";

      hosts = [
        {
          hostname = "wsl";
          nvimExtra = true;
          extraExternalModules = {
            system = [
              nixos-wsl.nixosModules.default
            ];
          };
          extraLocalModules = [
            "ai"
          ];
        }
        {
          hostname = "h56";
          nvimExtra = true;
          extraLocalModules = [
            "ai"
            "gui"
          ];
        }
        {
          hostname = "vps15358d36";
          extraExternalModules = {
            system = [
              disko.nixosModules.disko
            ];
          };
          extraLocalModules = [
            "server"
          ];
        }
        {
          hostname = "vps72c411b0";
          extraExternalModules = {
            system = [
              disko.nixosModules.disko
            ];
          };
          extraLocalModules = [
            "server"
          ];
        }

        # {
        #   hostname = "vps";
        #   system = "x86_64-linux";
        #   extraExternalModules = {
        #     system = [
        #       disko.nixosModules.disko
        #     ];
        #     home = [ ];
        #   };
        #   extraLocalModules = [
        #     "server"
        #   ];
        # }
      ];

    in
    {
      nixosConfigurations = nixpkgs.lib.foldl' (
        configs: host:
        let
          system = host.system or "x86_64-linux";
        in
        configs
        // {
          "${host.hostname}" = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit (host)
                extraLocalModules
                hostname
                ;
              inherit
                colorScheme
                inputs
                secretPath
                stateVersion
                system
                user
                ;
              pkgsStable = import nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };
            };
            modules = [
              ./host/${host.hostname}/system
              ./module/core/system
              ./module/extra/system
              sops-nix.nixosModules.sops
              stylix.nixosModules.stylix
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "backup";
                  extraSpecialArgs = {
                    inherit (host)
                      extraLocalModules
                      hostname
                      ;
                    inherit
                      colorScheme
                      inputs
                      secretPath
                      stateVersion
                      system
                      user
                      ;
                    nvimExtra = host.nvimExtra or false;
                    pkgsStable = import nixpkgs-stable {
                      inherit system;
                      config.allowUnfree = true;
                    };
                  };
                  users.${user} = {
                    imports = [
                      ./host/${host.hostname}/home
                      ./module/core/home
                      ./module/extra/home
                      nixvim.homeModules.nixvim
                      stylix.homeModules.stylix
                    ]
                    ++ (host.extraExternalModules.home or [ ]);
                    programs.nixvim.nixpkgs.source = nixpkgs;
                  };
                };
              }
            ]
            ++ (host.extraExternalModules.system or [ ]);
          };
        }
      ) { } hosts;
    };
}
