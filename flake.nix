{
  description = "debugloop/dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    gridx = {
      url = "git+ssh://git@github.com/debugloop/gridx";
      # url = "path:/home/danieln/code/gridx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-blink-cmp = {
      url = "github:Saghen/blink.cmp";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
    };
    wunschkonzert-install = {
      url = "git+ssh://git@github.com/debugloop/wunschkonzert-install";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    ...
  }: {
    formatter = {
      x86_64-linux = nixpkgs.legacyPackages.${nixpkgs.system}.alejandra;
    };
    homeConfigurations = let
      pkgs = nixpkgs.legacyPackages.${nixpkgs.system};
    in {
      "danieln" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home
        ];
        extraSpecialArgs = {
          inherit inputs;
        };
      };
    };
    nixosConfigurations = {
      simmons = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          hostname = "simmons";
        };
        modules = [
          ./hosts/common
          ./hosts/common/laptops.nix
          ./hosts/simmons
          ({...}: {
            home-manager.users.danieln = (
              {...}: {
                imports = [
                  ./home
                  ./home/wayland
                ];
              }
            );
          })
        ];
      };

      lusus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          hostname = "lusus";
        };
        modules = [
          ./hosts/common
          ./hosts/common/laptops.nix
          ./hosts/lusus
          ({...}: {
            home-manager.users.danieln = (
              {...}: {
                imports = [
                  ./home
                  ./home/wayland
                  inputs.gridx.home-module
                ];
              }
            );
          })
          inputs.niri.nixosModules.niri
        ];
      };

      hyperion = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          hostname = "hyperion";
        };
        modules = [
          ./hosts/common
          ./hosts/common/servers.nix
          ./hosts/hyperion
          ({...}: {
            home-manager.users.danieln = (
              {...}: {
                imports = [
                  ./home
                  ./home/headless.nix
                ];
              }
            );
          })
        ];
      };
    };
  };
}
