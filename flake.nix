{
  description = "debugloop/dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:viperML/nh";
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
            inputs.gridx.home-module
          ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
        danieln = home-manager.lib.homeManagerConfiguration {
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
          ({ system, ... }: {
            nixpkgs.overlays = [
              inputs.neovim-nightly-overlay.overlay
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.danieln = import ./home;
              extraSpecialArgs = {
                inherit inputs;
              };
            };
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
              inputs.neovim-nightly-overlay.overlay
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.danieln = (
                { ... }:
                {
                  imports = [
                    ./home
                    inputs.gridx.home-module
                  ];
                }
              );
              extraSpecialArgs = {
                inherit inputs;
              };
            };
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
          "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
          ./hosts/common
          ./hosts/common/servers.nix
          ./hosts/hyperion
          ({ system, ... }: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.danieln = import ./home/headless.nix;
              extraSpecialArgs = {
                inherit inputs;
              };
            };
          })
          # extra settings that only apply for the testvm
          ({ lib, ... }:
            {
              # empty password for myself
              age = lib.mkForce { };
              users.users.danieln.passwordFile = lib.mkForce null;
              users.users.danieln.initialHashedPassword = "";
              # launch in a useable and graphical window
              virtualisation.qemu.options = [ "-vga none -device virtio-vga-gl -display gtk,gl=on" ]; # -full-screen
            })
        ];
      };
    };
  };
}
