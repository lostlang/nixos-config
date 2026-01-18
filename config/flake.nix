{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";

    nixvim.url = "github:nix-community/nixvim";

    stylix.url = "github:danth/stylix/master";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixvim,
      stylix,
      nixos-wsl,
      ...
    }@inputs:
    let
      stateVersion = "25.11";
      user = "lostlang";
      timezone = "Asia/Almaty";
      colorScheme = import ./colorScheme;
      secret = import ./secret;

      hosts = [
        {
          hostname = "wsl";
          system = "x86_64-linux";
          extraExternalModules = [ nixos-wsl.nixosModules.default ];
          extraLocalModules = [ "wsl" ];
        }
        {
          hostname = "h56";
          system = "x86_64-linux";
          extraExternalModules = [ stylix.nixosModules.stylix ];
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
            system = host.system;
            specialArgs = {
              inherit (host)
                extraLocalModules
                hostname
                system
                ;
              inherit
                colorScheme
                inputs
                secret
                stateVersion
                timezone
                user
                ;
            };
            modules = [
              ./hosts/${host.hostname}
              ./system
            ]
            ++ (host.extraExternalModules or [ ]);
          };
        }
      ) { } hosts;

      homeConfigurations = nixpkgs.lib.foldl' (
        configs: host:
        configs
        // {
          "${user}@${host.hostname}" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs { system = host.system; };
            extraSpecialArgs = {
              inherit (host)
                extraLocalModules
                system
                ;
              inherit
                colorScheme
                inputs
                secret
                stateVersion
                timezone
                user
                ;
            };
            modules = [
              nixvim.homeModules.nixvim
              ./home
            ];
          };
        }
      ) { } hosts;
    };
}
