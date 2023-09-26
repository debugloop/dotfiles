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

      testvm = nixpkgs.lib.nixosSystem {
        # TODO: fix issues introduced with agenix and impermanence
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
          ./hosts/simmons
          # extra settings that only apply for the testvm
          ({ lib, ... }:
            {
              # empty password for myself
              users.users.danieln.initialHashedPassword = "";
              # launch in a useable and graphical window
              virtualisation.qemu.options = [ "-vga none -device virtio-vga-gl -display gtk,gl=on -full-screen" ];
              # fix mouse cursor
              environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
              # fix waybar not showing because its waiting on xdg portal which is delayed in VMs...
              xdg.portal.enable = lib.mkForce false;
            })
        ];
      };
    };
  };
}
