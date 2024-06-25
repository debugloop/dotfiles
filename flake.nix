{
  description = "debugloop/dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    gridx = {
      url = "git+ssh://git@github.com/debugloop/gridx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    formatter = {
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
    homeConfigurations =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in
      {
        "danieln@clarke" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home
            ({ ... }:
              {
                imports = [
                  inputs.gridx.home-module
                ];
              })
          ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
        "danieln@simmons" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
        "danieln@hyperion" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home/headless.nix ];
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
          ({ system, ... }: {
            nixpkgs.overlays = [
              # inputs.neovim-nightly-overlay.overlay
            ];
          })
        ];
      };

      clarke = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          hostname = "clarke";
        };
        modules = [
          ./hosts/common
          ./hosts/common/laptops.nix
          ./hosts/clarke
          ({ system, ... }: {
            nixpkgs.overlays = [
              # inputs.neovim-nightly-overlay.overlay
            ];
            home-manager.users.danieln = (
              { ... }:
              {
                imports = [
                  inputs.gridx.home-module
                ];
              }
            );
          })
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
        ];
      };

    };
  };
}
