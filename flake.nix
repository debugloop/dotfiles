{
  description = "debugloop/dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";

    # niri-unstable = {
    #   url = "github:YaLTeR/niri/a11fe23cbf6ba01ae4c23679aa2f7d7d8b44baf4";
    #   flake = false;
    # };
    niri = {
      url = "github:sodiboo/niri-flake";
      # inputs.niri-unstable.follows = "niri-unstable";
    };

    # private flakes
    gridx.url = "git+ssh://git@github.com/debugloop/gridx";
    # gridx.url = "path:/home/danieln/code/gridx";

    niri-autoselect-portal = {
      url = "git+https://codeberg.org/debugloop/niri-autoselect-portal.git";
    };

    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({self, ...}: let
      importTree = path: let
        entries = builtins.readDir path;
        toList = name: type:
          if type == "directory"
          then importTree (path + "/${name}")
          else if
            type == "regular"
            && builtins.match ".*\\.nix" name != null
            && builtins.match "_.*" name == null
          then [(path + "/${name}")]
          else [];
      in
        builtins.concatLists (builtins.attrValues (builtins.mapAttrs toList entries));

      mkHost = {
        hostname,
        system ? "x86_64-linux",
      }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            top = self;
            hostName = hostname;
          };
          modules = [./hosts/${hostname}/configuration.nix];
        };
    in {
      imports =
        (importTree ./modules)
        ++ [
          ({lib, ...}: {
            options.flake.modules = {
              nixos = lib.mkOption {
                type = lib.types.attrsOf lib.types.unspecified;
                default = {};
              };
              home = lib.mkOption {
                type = lib.types.attrsOf lib.types.unspecified;
                default = {};
              };
            };
          })
        ];

      systems = ["x86_64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        devShells.default = import ./devshell.nix {
          inherit pkgs;
          agenixPackage = inputs.agenix.packages.${system}.default;
        };

        packages = {
          host-keygen = import ./packages/host-keygen.nix {inherit pkgs;};
          nvim = import ./packages/nvim.nix {inherit pkgs;};
          infra = import ./packages/infra.nix {inherit pkgs inputs;};
          install = import ./packages/install.nix {
            inherit pkgs;
            self = inputs.self;
          };
        };

        formatter = import ./formatter.nix {
          inherit pkgs;
          pname = "formatter";
        };
      };

      flake = {
        nixosConfigurations =
          builtins.mapAttrs (hostname: _: mkHost {inherit hostname;})
          (inputs.nixpkgs.lib.filterAttrs (n: t: t == "directory" && builtins.match "_.*" n == null)
            (builtins.readDir ./hosts));

        lib = import ./lib {
          inherit inputs;
          flake = self;
        };
      };
    });
}
