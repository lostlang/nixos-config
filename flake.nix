{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager.url = "github:nix-community/home-manager/release-25.05";

    nixvim.url = "github:nix-community/nixvim";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    stylix.url = "github:danth/stylix/release-25.05";

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
      stateVersion = "25.05";
      user = "lostlang";
      hosts = [
        {
          hostname = "wsl";
          system_type = "workstation_cli";
          window_manager = "none";
        }
        {
          hostname = "h56";
          system_type = "workstation";
          window_manager = "hyprland";
        }
      ];

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
          "${host.hostname}" = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit
                inputs
                system
                stateVersion
                user
                ;
              inherit (host) hostname system_type window_manager;
            };
            modules =
              [
                ./hosts/${host.hostname}
                ./core
              ]
              ++ nixpkgs.lib.optionals (host.system_type == "workstation") [ stylix.nixosModules.stylix ]
              ++ nixpkgs.lib.optionals (host.hostname == "wsl") [ nixos-wsl.nixosModules.default ];
          };
        }
      ) { } hosts;

      homeConfigurations = nixpkgs.lib.foldl' (
        configs: host:
        configs
        // {
          "${user}@${host.hostname}" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${system};
            extraSpecialArgs = {
              inherit (host) system_type;
              inherit inputs stateVersion user;
            };

            modules = [
              nixvim.homeManagerModules.nixvim
              ./home
            ];
          };
        }
      ) { } hosts;
    };
}
